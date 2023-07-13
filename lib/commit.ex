defmodule Commit do
  import Error

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
  @space_separated_argument_mark_length @space_separated_argument_mark |> String.graphemes |> length
  @space_separated_argument_mark_reversed @space_separated_argument_mark |> String.reverse
  @space_separated_argument Error.unwrap! Regex.compile("#{Regex.escape(@space_separated_argument_mark)}(.+)#{Regex.escape(@space_separated_argument_mark)}", "s") # ~r/\^&(.+)\^&/

  # @title_pattern ~r/(?<type>[a-z-]+).+/
  
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
            {:ok, [ [word: lemma, sep: head[:sep]] | tail ] |> Tokenizer.join |> String.capitalize}
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

  def normalize_space_separated_arguments(description, []) do
    description
  end

  def normalize_space_separated_arguments(description, [ [ match, value ] | tail ]) do
    transformed_value = @spaces |> Regex.replace(value, "_")
    # IO.inspect match
    # IO.inspect description
    # IO.inspect description |> String.replace(match, "$#{@space_separated_argument_mark}#{transformed_value}")
    description |> normalize_space_separated_arguments(tail) |> String.replace(match, "$#{@space_separated_argument_mark}#{transformed_value}")
  end

  defp collect_space_separated_arguments(graphemes, value \\ [], prefix \\ [], inside_value \\ false, matches \\ []) # prefix is a space separated argument mark candidate - it consists of last n graphemes

  defp collect_space_separated_arguments([], value, prefix, inside_value, matches) do
    # matches

    # if prefix |> Llist.join("") == @space_separated_argument_mark_reversed do
    #   IO.inspect { nil, prefix, inside_value }
    # end

    if prefix |> Llist.join("") == @space_separated_argument_mark_reversed && inside_value do
      joined_value = value |> Llist.reverse |> Llist.join('')
      [ [ "#{@space_separated_argument_mark}#{joined_value}", joined_value |> String.slice(0..-(@space_separated_argument_mark_length + 1)) ] | matches ]
    else
      matches
    end |> Llist.reverse
  end

  defp collect_space_separated_arguments([ head | tail ], value, prefix, inside_value, matches) do
    next_prefix = if prefix |> length < @space_separated_argument_mark_length do
      [ head | prefix ]
    else
      [ head | prefix |> Llist.drop_last ]
    end

    # IO.inspect { head, prefix, inside_value, value }

    if prefix |> Llist.join("") == @space_separated_argument_mark_reversed do
      collect_space_separated_arguments(tail, [head], next_prefix, !inside_value,
        if inside_value do
          joined_value = value |> Llist.reverse |> Llist.join('')
          [ [ "#{@space_separated_argument_mark}#{joined_value}", joined_value |> String.slice(0..-(@space_separated_argument_mark_length + 1)) ] | matches ]
        else
          matches
        end
      )
    else
      collect_space_separated_arguments(
        tail,
        if inside_value do
          [ head | value ]
        else
          value
        end,
        next_prefix, inside_value, matches
      )
    end

  end

  def scan_for_space_separated_arguments(description) do
    description |> String.graphemes |> collect_space_separated_arguments # |> IO.inspect

    # []
  end

  def parse(title, description \\ nil) when title != nil do
    # IO.inspect(title)
    # IO.inspect description

    description_props = case description do
      nil -> []
      _ ->
        if @debug do
          description |> scan_for_space_separated_arguments
          # description = description |> normalize_space_separated_arguments(Regex.scan(@space_separated_argument, description)) # |> IO.inspect
          # for [match, value] <- Regex.scan(@space_separated_argument, description) do
          #   transformed_value = @spaces |> Regex.replace(value, "_")
          #   description = String.replace(description, match, "$#{@space_separated_argument_mark}#{transformed_value}") |> IO.inspect
          # end
          # IO.inspect Regex.scan(@command, description)
        end

        # {description, commands} = parse_commands(description, Regex.scan(@command, description |> normalize_space_separated_arguments(Regex.scan(@space_separated_argument, description))))
        normalized_description = description |> normalize_space_separated_arguments(description |> scan_for_space_separated_arguments)
        # IO.inspect normalized_description
        {description, commands} = parse_commands(description, Regex.scan(@command, normalized_description))

        if @debug do
          IO.inspect "Commands:"
          IO.inspect commands
        end

        [description: description |> Formatter.parse_body, commands: commands]

        # if length(commands) > 0 do
        #   [[command, command_name] | _tail] = commands

        #   description = description |> String.replace(command, "")

        #   IO.inspect description
        #   # IO.inspect commands
        # end
    end

    case Regex.named_captures(@long_title_pattern, title) do
      nil ->
        case Regex.named_captures(@short_title_pattern, title) do
          nil -> {:error, "Cannot parse commit title"}
          captures -> 
            case make_task_title(captures["description"]) do
              {:ok, name} -> {:ok, Llist.merge([name: name, labels: [captures["type"]]], description_props)}
              result -> result
            end
        end
      captures -> 
        wrap captures["description"] |> make_task_title, handle: fn name -> Llist.merge([name: name, labels: [captures["type"] | @spaces |> Regex.split(captures["scope"])]], description_props) end
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
