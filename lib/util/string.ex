defmodule Tiger.Util.String do
  import Tiger.Util.Collection, only: [reverse: 1]

  @spaces ~r/\s+/
  @punctuation ~r/\p{P}/

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
    graphemes |> Tiger.Util.Collection.join("")
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

  # match

  def space?(string) do
    Regex.match?(@spaces, string)
  end

  def punctuation?(string) do
    Regex.match?(@punctuation, string)
  end
end
