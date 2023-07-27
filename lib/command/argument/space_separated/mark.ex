defmodule Tiger.Command.Argument.SpaceSeparated.Mark do
  import Llist, only: [drop_last: 1]
  import Tiger.Util.String, only: [join: 1]

  @mark "^&"

  @mark_length @mark |> String.graphemes |> length
  @mark_reversed @mark |> String.reverse

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

  def add_heading_mark(occurrence) do
    "#{@mark}#{occurrence}"
  end

  def drop_trailing_mark(argument) do
    argument |> String.slice(
      0..-(@mark_length + 1)
    )
  end
end
