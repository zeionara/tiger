defmodule Tiger.Util.String do
  import Llist, only: [reverse: 1]

  def join(graphemes) do
    graphemes |> Llist.join("")
  end

  def rjoin(graphemes) do
    graphemes |> reverse |> join
  end
end
