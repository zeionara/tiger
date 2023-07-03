defmodule Commit do
  @moduledoc """
  Commit parser and adapter for working with trello interface
  """

  # @title_pattern ~r/(?<type>[a-z-]+)\\((?<scope>[^)])\)/
  @long_title_pattern ~r/^(?<type>[a-z-]+)\((?<scope>.+)\):\s+(?<description>.+)\s*$/
  @short_title_pattern ~r/^(?<type>[a-z-]+):\s+(?<description>.+)\s*$/
  # @title_pattern ~r/(?<type>[a-z-]+).+/
  
  defp lemmatize(word) do
    :en |> Lemma.new |> Lemma.parse(word)
  end
  
  defp make_task_title(commit_title) when commit_title != nil do
    case Tokenizer.split(commit_title) do
      {:ok, tokens} ->
        case (tokens |> Enum.at(0))[:word] |> lemmatize do
          {:ok, lemma} -> IO.inspect(lemma)
          result -> result
        end
      result -> result
    end
  end

  def parse(title, description \\ nil) when title != nil do
    IO.inspect(title)
    IO.inspect(description)

    case Regex.named_captures(@long_title_pattern, title) do
      nil ->
        case Regex.named_captures(@short_title_pattern, title) do
          nil -> {:error, "Cannot parse commit title"}
          captures -> make_task_title(captures["description"])
        end
      captures -> make_task_title(captures["description"])
    end
  end
end