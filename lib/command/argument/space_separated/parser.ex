defmodule Tiger.Command.Argument.SpaceSeparated.Parser do
  import Tiger.Command.Argument.SpaceSeparated.Mark
  import Tiger.Command.Argument.SpaceSeparated.Struct

  import Error, only: [wrap: 2]

  @incomplete_argument_message "Incomplete argument at the end of the string"

  defp collect_space_separated_arguments(graphemes, argument \\ nil, prefix \\ []) # prefix is a space separated argument mark candidate - it consists of last n graphemes

  defp collect_space_separated_arguments([], argument, prefix) do
    if is_mark(prefix) do
      if argument == nil do
        {:error, @incomplete_argument_message}
      else
        {:ok, [init(argument)]}
      end
    else
      if argument == nil do
        {:ok, []}
      else
        {:error, @incomplete_argument_message}
      end
    end
  end

  # @spec collect_space_separated_arguments(list(), char(), String.t(), boolean(), list(string()))
  defp collect_space_separated_arguments([ head | tail ], argument, prefix) do
    next_prefix = prepend(head, prefix)

    if is_mark(prefix) do
      wrap collect_space_separated_arguments(tail, (if argument == nil, do: [head], else: nil), next_prefix), handle: fn arguments ->
        if argument == nil do
          arguments
        else
          [
            init(argument) | arguments
          ]
        end
      end
    else
      collect_space_separated_arguments(tail, (if argument == nil, do: argument, else: [ head | argument ]), next_prefix)
    end
  end

  # @spec find_space_separated_arguments(string()) :: list()
  def find_all(string) do
    string |> String.graphemes |> collect_space_separated_arguments
  end
end
