defmodule Tiger.Command.Argument.Mark do
  @mark "$"

  @mark_length @mark |> String.graphemes |> length

  def add_heading_mark(argument) do
    "#{@mark}#{argument}"
  end

  def drop_heading_mark(argument) do
    argument |> String.slice(
      @mark_length..-1
    )
  end

  def starts_with_mark?(string) do
    String.starts_with?(string, @mark)
  end
end
