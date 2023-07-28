defmodule Tiger.Command.Argument.Mark do
  @mark "$"

  @length @mark |> String.graphemes |> length

  def add_heading_mark(argument) do
    "#{@mark}#{argument}"
  end

  def drop_heading_mark(argument) do
    argument |> String.slice(
      @length..-1
    )
  end

  def starts_with_mark?(string) do
    String.starts_with?(string, @mark)
  end
end
