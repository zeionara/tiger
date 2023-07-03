defmodule Tokenizer do

  @space ~r/\s+/
  @alphanumeric ~r/[\w\d]+/

  defp _collect_tokens(graphemes, current_word \\ [], current_sep \\ [], parsing_word \\ true, tokens \\ [])

  defp _collect_tokens([], current_word, current_sep, _parsing_word, tokens) do
    {:ok, [[word: current_word |> Llist.reverse |> Llist.join(""), sep: current_sep |> Llist.reverse |> Llist.join("")] | tokens]}
  end

  defp _collect_tokens([head | tail], current_word, current_sep, parsing_word, tokens) do
    if Regex.match?(@alphanumeric, head) do
      if parsing_word do
        _collect_tokens(tail, [head | current_word], [], true, tokens)
      else
        _collect_tokens(tail, [head], [], true, [[word: current_word |> Llist.reverse |> Llist.join(""), sep: current_sep |> Llist.reverse |> Llist.join("")] | tokens])
      end
    else
      if Regex.match?(@space, head) do
        _collect_tokens(tail, current_word, [head | current_sep], false, tokens)
      else # if punctuation
        _collect_tokens(tail, [head], [], false, [[word: current_word |> Llist.reverse |> Llist.join(""), sep: current_sep |> Llist.reverse |> Llist.join("")] | tokens])
      end
    end
  end

  defp collect_tokens(graphemes) do
    case _collect_tokens(graphemes) do
      {:ok, tokens} -> {:ok, tokens |> Llist.reverse}
      {:error, message} -> {:error, message}
    end
  end

  def split(text) do
    # text |> String.graphemes |> IO.inspect
    text |> String.graphemes |> collect_tokens
    # case text |> String.graphemes |> collect_tokens do
    #   {:ok, tokens} ->
    #     IO.inspect((tokens |> Enum.at(0))[:word])
    #   result -> result
    # end
  end

  def join([]) do
    ""
  end

  def join([ head | tail ]) do
    "#{head[:word]}#{head[:sep]}#{join(tail)}"
  end
end
