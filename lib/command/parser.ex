defmodule Tiger.Command.ParsingResult do
  defstruct [:string, :commands]
end

defmodule Tiger.Command.Parser do
  import Tiger.Util.String, only: [rm: 2]
  import Error, only: [wrap: 2, wrapn: 2]

  alias Tiger.Command.Argument.Mark, as: Am
  alias Tiger.Command, as: Command

  # @command ~r/!([a-z\-]+)\s*((?:\$[^\s]+\s*)*)/
  @command Regex.compile!("!([a-z\-]+)\\s*((?:#{"" |> Am.add_heading_mark |> Regex.escape}[^\\s]+\\s*)*)")

  defp parse_many(description, []) do
    {:ok, {description, []}}
  end

  defp parse_many(description, [[occurrence, name, args] | []]) do
    wrap Command.init(name, args), handle: fn command ->
      {
        description |> rm(occurrence), 
        [command]
      }
    end
  end

  defp parse_many(string, [[occurrence, name, args] | tail]) do
    wrap parse_many(string |> rm(occurrence), tail), handle: fn result ->
      { description, commands } = result

      wrapn Command.init(name, args), handle: fn command ->
        {
          description, 
          [command | commands]
        }
      end
    end
  end

  def find_all(string) do
    wrap string |> parse_many(Regex.scan(@command, string)), handle: fn {string, commands} ->
      %Tiger.Command.ParsingResult{
        string: string |> String.trim,
        commands: commands
      }
    end
  end
end
