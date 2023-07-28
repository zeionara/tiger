defmodule Commit do
  import Error
  alias Tiger.Command.Argument.SpaceSeparated.Parser, as: Ssap
  alias Tiger.Command.Argument.SpaceSeparated.Struct, as: Ssa
  alias Tiger.Command.Argument.SpaceSeparated.Normalizer, as: Ssan

  alias Tiger.Command.Parser, as: Command

  @debug true

  @moduledoc """
  Commit parser and adapter for working with trello interface
  """

  # @title_pattern ~r/(?<type>[a-z-]+)\\((?<scope>[^)])\)/
  @spaces ~r/\s+/
  @long_title_pattern ~r/^(?<type>[a-z-]+)\((?<scope>.+)\):\s+(?<description>.+)\s*$/
  @short_title_pattern ~r/^(?<type>[a-z-]+):\s+(?<description>.+)\s*$/

  # @command ~r/!([a-z\-]+)\s*/
  @command ~r/!([a-z\-]+)\s*((?:\$[^\s]+\s*)*)/
  
  @space_separated_argument_mark "^&"
  
  defp lemmatize(word) do
    if @debug do
      {:ok, "make"}
    else
      :en |> Lemma.new |> Lemma.parse(word)
    end
  end

  defp make_task_title(commit_title) when commit_title != nil do
    case Tokenizer.split(commit_title) do
      {:ok, tokens} ->
        case (tokens |> Enum.at(0))[:word] |> lemmatize do
          {:ok, lemma} ->
            [ head | tail ] = tokens
            {:ok, { [ [word: lemma, sep: head[:sep]] | tail ] |> Tokenizer.join |> String.capitalize, tokens}}
          result -> result
        end
      result -> result
    end
  end

  def parse_command(command_name, command_args) do
    # IO.inspect { command_name, command_args }

    args = @spaces |> Regex.split(command_args) |> Llist.transform(
      map: fn x ->
        x = String.slice(x, 1..-1)

        if String.starts_with?(x, @space_separated_argument_mark) do
          x |> String.slice(2..-1) |> String.replace("_", " ") |> String.trim
        else
          x
        end
      end,
      filter: fn x ->
        x != ""
      end,
      split: fn x ->
        x |> String.split(@space_separated_argument_mark)
      end
    ) # |> IO.inspect

    # IO.inspect args

    case { command_name, args } do
      { "create", [] } -> { :create, nil }
      { "create", [ lemmatization_spec ] } -> { :create, lemmatization_spec }
      { "close", [ symbol ] } -> { :close, symbol }
      { "make", [ name ] } -> { :make, name }
      { "make", [ name, description ] } -> { :make, [name: name |> String.trim, description: description |> String.trim] }
      _ -> nil
    end
  end

  def parse_commands(description, []) do
    {description, []}
  end

  def parse_commands(description, [[command, command_name, command_args] | []]) do
    # IO.inspect { command, command_name, command_args }

    {
      description |> String.replace(command, ""), 
      case parse_command(command_name, command_args) do
        nil -> []
        command -> [command]
      end
    }
  end

  def parse_commands(description, [[command, command_name, command_args] | tail]) do
    # IO.inspect tail

    {description, commands} = parse_commands(description |> String.replace(command, ""), tail)

    {
      description, 
      case parse_command(command_name, command_args) do
        nil -> commands
        command -> [command | commands]
      end
    }
  end

  def parse(title, description \\ nil) when title != nil do
    # IO.inspect(title)
    # IO.inspect description

    {:ok, description_props} = case description do
      nil -> []
      _ ->
        if @debug do
          description |> Ssap.find_all |> IO.inspect
        end

        # {description, commands} = parse_commands(description, Regex.scan(@command, description |> normalize_space_separated_arguments(Regex.scan(@space_separated_argument, description))))
        wrap description |> Ssap.find_all, handle: fn ssaps ->
          normalized_description = Ssan.normalize(description, ssaps)

          description
          |> Ssan.normalize(ssaps)
          |> Command.find_all
          |> IO.inspect

          {description, commands} = parse_commands(description, Regex.scan(@command, normalized_description))
          [description: description |> Formatter.parse_body, commands: commands]
        end
    end

    case Regex.named_captures(@long_title_pattern, title) do
      nil ->
        case Regex.named_captures(@short_title_pattern, title) do
          nil -> {:error, "Cannot parse commit title"}
          captures -> 
            case make_task_title(captures["description"]) do
              {:ok, {name, tokens}} ->
                {:ok, Llist.merge([name: name, labels: [captures["type"]], tokens: tokens], description_props)}
              result -> result
            end
        end
      captures -> 
        wrap captures["description"] |> make_task_title, handle: fn {name, tokens} -> 
          Llist.merge([
            name: name,
            labels: [captures["type"] | @spaces |> Regex.split(captures["scope"])],
            tokens: tokens
          ], description_props)
        end
        # wrap(
        #   make_task_title(captures["description"]),
        #   quote do [name: result, labels: [captures["type"], captures["scope"]]] end
        # )
        # case make_task_title(captures["description"]) do
        #   {:ok, name} -> {:ok, [name: name, labels: [captures["type"], captures["scope"]]]}
        #   result -> result
        # end
    end
  end
end
