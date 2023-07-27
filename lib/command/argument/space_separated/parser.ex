defmodule Tiger.Command.Argument.SpaceSeparated.Parser do
  import Tiger.Command.Argument.SpaceSeparated.Mark
  import Tiger.Command.Argument.SpaceSeparated.Struct

  import Llist, only: [reverse: 1]

  defp collect_space_separated_arguments(graphemes, argument \\ nil, prefix \\ []) # prefix is a space separated argument mark candidate - it consists of last n graphemes

  defp collect_space_separated_arguments([], argument, prefix) do
    if is_mark(prefix) && argument != nil do
      [
        init(argument)
      ]
    else
      []
    end |> reverse
  end

  # @spec collect_space_separated_arguments(list(), char(), String.t(), boolean(), list(string()))
  defp collect_space_separated_arguments([ head | tail ], argument, prefix) do
    next_prefix = prepend(head, prefix)

    if is_mark(prefix) do
      arguments = collect_space_separated_arguments(tail,
        if argument == nil do
          [head]
        else
          nil
        end,
        next_prefix
      )

      if argument != nil do
        [
          init(argument) | arguments
        ]
      else
        arguments
      end
    else
      collect_space_separated_arguments(tail,
        if argument != nil do
          [ head | argument ]
        else
          argument
        end,
        next_prefix
      )
    end

  end

  # @spec find_space_separated_arguments(string()) :: list()
  def find_all(string) do
    string |> String.graphemes |> collect_space_separated_arguments
  end
end
