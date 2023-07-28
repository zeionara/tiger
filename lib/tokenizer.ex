defmodule Tokenizer do
  alias Tiger.Text.Struct, as: Text
  alias Tiger.Text.Token, as: Token

  import Error, only: [wrap: 2]

  @space ~r/\s+/
  @alphanumeric ~r/[\w\d]+/

  defp collect_tokens(graphemes, token \\ nil, separator \\ nil)

  defp collect_tokens([], token, separator) do
    {:ok, [Token.init(token, separator)]}
  end

  defp collect_tokens([head | tail], token, separator) do
    if Regex.match?(@alphanumeric, head) do
      if separator == nil do
        collect_tokens(tail, (if token == nil, do: [head], else: [head | token]), nil)
      else
        wrap collect_tokens(tail, [head], nil), handle: fn tokens ->
          [ Token.init(token, separator) | tokens ]
        end
      end

      # if parsing_word do
      #   _collect_tokens(tail, [head | current_word], [], true, tokens)
      # else
      #   _collect_tokens(tail, [head], [], true, [[word: current_word |> Llist.reverse |> Llist.join(""), sep: current_sep |> Llist.reverse |> Llist.join("")] | tokens])
      # end
    else
      if Regex.match?(@space, head) do
        collect_tokens(tail, token, (if separator == nil, do: [head], else: [head | separator])) 
      else
        wrap collect_tokens(tail, [head], nil), handle: fn tokens ->
          [ Token.init(token, separator) | tokens ]
        end
      end

      # if Regex.match?(@space, head) do
      #   _collect_tokens(tail, current_word, [head | current_sep], false, tokens)
      # else # if punctuation
      #   _collect_tokens(tail, [head], [], false, [[word: current_word |> Llist.reverse |> Llist.join(""), sep: current_sep |> Llist.reverse |> Llist.join("")] | tokens])
      # end
    end
  end

  # defp collect_tokens(graphemes) do
  #   case _collect_tokens(graphemes) do
  #     {:ok, tokens} -> {:ok, tokens |> Llist.reverse}
  #     {:error, message} -> {:error, message}
  #   end
  # end

  def split(string) do
    string |> String.graphemes |> collect_tokens
  end

  def join([]) do
    ""
  end

  def join([ head | tail ]) do
    "#{head[:word]}#{head[:sep]}#{join(tail)}"
  end

  def tokenize(text) do
    wrap split(text), handle: fn tokens ->
      %Text{
        raw: text,
        tokens: tokens
      }
    end
  end
end
