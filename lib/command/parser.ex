defmodule Tiger.Command.Parser do
  import Tiger.Util.String, only: [rm: 2, ss: 1]
  import Error, only: [wrap: 2, wrapn: 2]

  alias Tiger.Command.Argument.Mark, as: Am
  alias Tiger.Command.Struct, as: Command
  alias Tiger.Command.Argument.SpaceSeparated.Normalizer, as: Ssan

  # @command ~r/!([a-z\-]+)\s*((?:\$[^\s]+\s*)*)/
  @command Regex.compile!("!([a-z\-]+)\\s*((?:#{"" |> Am.add_heading_mark |> Regex.escape}[^\\s]+\\s*)*)")

  def parse_one(name, args) do
    args = args |> ss |> Llist.transform(
      map: fn x ->
        x |> Am.drop_heading_mark |> Ssan.denormalize
      end,
      filter: fn x ->
        x != ""
      end
    )

    case { name, args } do
      { "create", [] } -> {:ok, Command.init(:create, [])}
      { "create", [ lemmatization_spec ] } -> {:ok, Command.init(:create, [lemmatization_spec])}
      { "close", [ symbol ] } -> {:ok, Command.init(:close, [symbol])}
      { "make", [ title ] } -> {:ok, Command.init(:make, [title])}
      { "make", [ title, description ] } -> {:ok, Command.init(:make, [name: title |> String.trim, description: description |> String.trim])}

      _ -> {:error, "Unrecognized task #{name}"}
    end
  end

  defp parse_many(description, []) do
    {:ok, {description, []}}
  end

  defp parse_many(description, [[occurrence, name, args] | []]) do
    wrap parse_one(name, args), handle: fn command ->
      {
        description |> rm(occurrence), 
        [command]
      }
    end
  end

  defp parse_many(string, [[occurrence, name, args] | tail]) do
    wrap parse_many(string |> rm(occurrence), tail), handle: fn result ->
      { description, commands } = result

      wrapn parse_one(name, args), handle: fn command ->
        {
          description, 
          [command | commands]
        }
      end
    end
  end

  def find_all(string) do
    string |> parse_many(Regex.scan(@command, string))
    # wrap string |> parse_many(Regex.scan(@command, string)), handle: fn {description, commands} -> 
    #   {description, commands}
    # end
  end
end
