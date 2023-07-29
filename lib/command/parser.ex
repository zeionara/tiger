defmodule Tiger.Command.ParsingResult do
  defstruct [:string, :commands]
end

defmodule Tiger.Command.Parser do
  import Tiger.Util.String, only: [rm: 2]
  import Tiger.Error, only: [get: 2]

  alias Tiger.Command.Argument.Mark, as: Am
  alias Tiger.Command, as: Command

  # @command ~r/!([a-z\-]+)\s*((?:\$[^\s]+\s*)*)/
  @command Regex.compile!("!([a-z\-]+)\\s*((?:#{"" |> Am.add_heading_mark |> Regex.escape}[^\\s]+\\s*)*)")

  defp parse_many(description, []) do
    {:ok, {description, []}}
  end

  defp parse_many(description, [[occurrence, name, args] | []]) do
    get command: Command.init(name, args) do
      {
        description |> rm(occurrence),
        [command]
      }
    end
  end

  defp parse_many(string, [[occurrence, name, args] | tail]) do
    get result: parse_many(string |> rm(occurrence), tail) do
      { description, commands } = result

      get command: Command.init(name, args) do
        {
          description, 
          [command | commands]
        }
      end
    end
  end

  def find_all(string) do
    get result: string |> parse_many(Regex.scan(@command, string)) do
      { string, commands } = result

      %Tiger.Command.ParsingResult{
        string: string |> String.trim,
        commands: commands
      }
    end
  end
end
