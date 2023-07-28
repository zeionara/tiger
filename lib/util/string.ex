defmodule Tiger.Util.String do
  import Llist, only: [reverse: 1]

  @spaces ~r/\s+/
  @underscore "_"

  def join(graphemes) do
    graphemes |> Llist.join("")
  end

  def rjoin(graphemes) do
    graphemes |> reverse |> join
  end

  def replace_spaces(string, replacement \\ @underscore) do
    @spaces |> Regex.replace(string, replacement)
  end
end
