defmodule Tiger.Commit.Parser do
  import Error
  alias Tiger.Command.Argument.SpaceSeparated.Parser, as: Ssap
  alias Tiger.Command.Argument.SpaceSeparated.Normalizer, as: Ssan

  alias Tiger.Command.Parser, as: Command

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
            wrap Tokenizer.tokenize(captures["description"]), handle: fn text ->
              %Tiger.Commit.Title{
                type: captures["type"],
                content: text
              }
            end
        end
      captures -> 
        wrap Tokenizer.tokenize(captures["description"]), handle: fn text -> 
          %Tiger.Commit.Title{
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
        wrap description |> Ssap.find_all, handle: fn ssaps ->
          wrapn description |> Ssan.normalize(ssaps) |> Command.find_all, handle: fn %Tiger.Command.ParsingResult{commands: commands, string: content} ->
            %Tiger.Commit.Description{
              content: content,
              commands: commands
            }
          end
        end
    end
  end

  def parse(title, description \\ nil) when title != nil do
    wrap parse_title(title), handle: fn title ->
      wrapn parse_description(description), handle: fn description ->
        %Tiger.Commit.Message{
          title: title,
          description: description
        }
      end
    end
  end
end
