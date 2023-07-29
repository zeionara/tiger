 defmodule Tiger.Text.Tokenizer do
  alias Tiger.Text, as: Text
  alias Tiger.Text.Token, as: Token

  import Tiger.Util.String, only: [space?: 1, punctuation?: 1]
  import Tiger.Error, only: [set: 2]

  # split

  defp collect_tokens(graphemes, token \\ nil, separator \\ nil)

  defp collect_tokens([], token, separator) do
    case {token, separator} do
      {nil, nil} -> {:error, "Either token either separator must be defined"} # this happens when an empty list of graphemes is passed directly into the private method
      _ -> {:ok, [Token.init(token, separator)]}
    end
  end

  defp collect_tokens([head | tail], token, separator) do
    if space?(head) do
      collect_tokens(tail, token, (if separator == nil, do: [head], else: [head | separator])) 
    else
      if punctuation?(head) do
        set tokens: collect_tokens(tail, [head], []) do
          [ Token.init(token, separator) | tokens ]
        end
      else
        if separator == nil do
          collect_tokens(tail, (if token == nil, do: [head], else: [head | token]), nil)
        else
          set tokens: collect_tokens(tail, [head], nil) do
            [ Token.init(token, separator) | tokens ]
          end
        end
      end
    end
  end

  def split(string) do
    if string == "" do
      {:ok, []}
    else
      string |> String.graphemes |> collect_tokens
    end
  end

  def tokenize(text) do
    set tokens: split(text) do
      %Text{raw: text, tokens: tokens}
    end
  end

  # join

  def join([]) do
    ""
  end

  def join([ %Token{raw: raw, sep: sep} | tail ]) do
    "#{if raw == nil, do: "", else: raw}#{if sep == nil, do: "", else: sep}#{join(tail)}"
  end
end
