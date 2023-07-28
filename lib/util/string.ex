defmodule Tiger.Util.String do
  import Llist, only: [reverse: 1]

  @spaces ~r/\s+/

  @space " "
  @underscore "_"
  @empty ""

  def join(graphemes) do
    graphemes |> Llist.join("")
  end

  def rjoin(graphemes) do
    graphemes |> reverse |> join
  end

  def replace_spaces(string, replacement \\ @underscore) do
    @spaces |> Regex.replace(string, replacement)
  end

  def replace_to_spaces(string, replacement \\ @underscore) do
    String.replace(string, replacement, @space)
  end

  def rm(string, substring) do
    string |> String.replace(substring, @empty)
  end

  def ss(string) do
    Regex.split(@spaces, string)
  end
end
