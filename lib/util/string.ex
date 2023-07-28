defmodule Tiger.Util.String do
  import Llist, only: [reverse: 1]

  @spaces ~r/\s+/

  @space " "
  @underscore "_"
  @empty ""
  @comma ","

  def rm(string, substring) do
    string |> String.replace(substring, @empty)
  end

  # replace

  def replace_spaces(string, replacement \\ @underscore) do
    @spaces |> Regex.replace(string, replacement)
  end

  def replace_to_spaces(string, replacement \\ @underscore) do
    String.replace(string, replacement, @space)
  end

  # join

  def join(graphemes) do
    graphemes |> Llist.join("")
  end

  def rjoin(graphemes) do # reverse join
    graphemes |> reverse |> join
  end

  # split

  def ss(string) do # Split by Spaces
    Regex.split(@spaces, string)
  end

  def sc(string) do # Split by Commas
    for item <- String.split(string, @comma) do
      String.trim(item)
    end
  end
end
