defmodule Tiger.Command.Argument.SpaceSeparated.Mark do
  import Llist, only: [drop_last: 1]
  import Tiger.Util.String, only: [join: 1]

  @mark "^&"

  @mark_length @mark |> String.graphemes |> length
  @mark_reversed @mark |> String.reverse
  # @space_separated_argument Error.unwrap! Regex.compile("#{Regex.escape(@space_separated_argument_mark)}(.+)#{Regex.escape(@space_separated_argument_mark)}", "s") # ~r/\^&(.+)\^&/

  def is_mark (graphemes) do
    graphemes |> join == @mark_reversed
  end

  def prepend(grapheme, prefix) do
    if length(prefix) < @mark_length do
      [ grapheme | prefix ]
    else
      [ grapheme | prefix |> drop_last ]
    end
  end

  def add_heading_mark(argument) do
    "#{@mark}#{argument}"
  end

  def drop_trailing_mark(argument) do
    argument |> String.slice(
      0..-(@mark_length + 1)
    )
  end
end
