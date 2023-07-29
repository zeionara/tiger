defmodule Tiger.Command.Argument.SpaceSeparated.Mark do
  import Tiger.Util.Collection, only: [drop_last: 1]
  import Tiger.Util.String, only: [join: 1]

  @mark "^&"

  @length @mark |> String.graphemes |> length
  @reversed @mark |> String.reverse
  # @space_separated_argument Error.unwrap! Regex.compile("#{Regex.escape(@space_separated_argument_mark)}(.+)#{Regex.escape(@space_separated_argument_mark)}", "s") # ~r/\^&(.+)\^&/

  def is_mark (graphemes) do
    graphemes |> join == @reversed
  end

  def prepend(grapheme, prefix) do
    if length(prefix) < @length do
      [ grapheme | prefix ]
    else
      [ grapheme | prefix |> drop_last ]
    end
  end

  def add_heading_mark(argument) do
    "#{@mark}#{argument}"
  end

  def drop_heading_mark(argument) do
    argument |> String.slice(
      @length..-1
    )
  end

  def drop_trailing_mark(argument) do
    argument |> String.slice(
      0..-(@length + 1)
    )
  end

  def starts_with_mark?(string) do
    String.starts_with?(string, @mark)
  end
end
