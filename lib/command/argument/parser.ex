defmodule Tiger.Command.Argument.Parser do
  alias Tiger.Command.Argument.Mark, as: Am

  def denormalize(string) do
    if Am.starts_with_mark?(string) do
      string |> Am.drop_heading_mark |> String.trim
    else
      string
    end
  end
end
