defmodule Tiger.Commit.Title do
  defstruct [:type, :scope, :content]

  def labels(%Tiger.Commit.Title{type: type, scope: scope}) do
    [ type | scope |> Tiger.Util.String.sc ]
  end
end
