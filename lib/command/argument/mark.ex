defmodule Tiger.Command.Argument.Mark do
  @mark "$"

  def add_heading_mark(argument) do
    "#{@mark}#{argument}"
  end
end
