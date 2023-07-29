defmodule Tiger.Commit.Parser do
  alias Tiger.Command.Argument.SpaceSeparated.Parser, as: Ssap
  alias Tiger.Command.Argument.SpaceSeparated.Normalizer, as: Ssan

  alias Tiger.Command.Parser, as: Command

  alias Tiger.Text.Tokenizer, as: Tokenizer
  alias Tiger.Commit.Title, as: Title
  alias Tiger.Commit.Description, as: Description
  alias Tiger.Commit.Message, as: Message

  import Tiger.Error, only: [get: 2, set: 2]

  @moduledoc """
  Commit parser and adapter for working with trello interface
  """

  @long_title_pattern ~r/^(?<type>[a-z-]+)\((?<scope>.+)\):\s+(?<description>.+)\s*$/
  @short_title_pattern ~r/^(?<type>[a-z-]+):\s+(?<description>.+)\s*$/

  defp parse_title(title) do
    case Regex.named_captures(@long_title_pattern, title) do
      nil ->
        case Regex.named_captures(@short_title_pattern, title) do
          nil -> {:error, "Incorrect commit title '#{title}' - missing prefix"}
          captures ->
            set text: Tokenizer.tokenize(captures["description"]) do
              %Title{
                type: captures["type"],
                content: text
              }
            end
        end
      captures -> 
        set text: Tokenizer.tokenize(captures["description"]) do
          %Title{
            type: captures["type"],
            scope: captures["scope"],
            content: text
          }
        end
    end
  end

  defp parse_description(description) do
    case description do
      nil -> nil
      description ->
        get args: description |> Ssap.find_all do
          set result: description |> Ssan.normalize(args) |> Command.find_all do
            %Description{
              content: result.string,
              commands: result.commands
            }
          end
        end
    end
  end

  def parse(title, description \\ nil) when title != nil do
    get title: parse_title(title) do
      set description: parse_description(description) do
        %Message{
          title: title,
          description: description
        }
      end
    end
  end
end
