defmodule Tiger.Command.Argument.SpaceSeparated.Normalizer do
  alias Tiger.Command.Argument.SpaceSeparated.Struct, as: Ssa

  import Tiger.Util.String
  alias Tiger.Command.Argument.SpaceSeparated.Mark, as: Ssam
  alias Tiger.Command.Argument.Mark, as: Am

  def normalize(description, []) do
    description
  end

  def normalize(description, [ %Ssa{occurrence: occurrence, value: value} | tail ]) do
    description
    |> normalize(tail)
    |> String.replace(
      occurrence,
      value
      |> replace_spaces
      |> Ssam.add_heading_mark
      |> Am.add_heading_mark
    )
  end

  def denormalize(string) do
    if Ssam.starts_with_mark?(string) do
      string |> Ssam.drop_heading_mark |> replace_to_spaces |> String.trim
    else
      string
    end
  end
end
