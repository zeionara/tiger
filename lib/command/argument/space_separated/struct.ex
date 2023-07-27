defmodule Tiger.Command.Argument.SpaceSeparated.Struct do
  import Tiger.Util.String, only: [rjoin: 1]
  import Tiger.Command.Argument.SpaceSeparated.Mark, only: [add_heading_mark: 1, drop_trailing_mark: 1]

  defstruct [:occurrence, :value]

  def init(graphemes) do
    joined = graphemes |> rjoin

    %Tiger.Command.Argument.SpaceSeparated.Struct{
      occurrence: joined |> add_heading_mark,
      value: joined |> drop_trailing_mark
    }
  end
end
