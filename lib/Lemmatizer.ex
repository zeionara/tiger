defmodule Lemmatizer do
  @debug false
  @spaces ~r/\s+/
  @argument_separator "@"

  import Error, only: [wrap: 2, wrapn: 2]

  defp parse_spec_([]) do
    {:ok, []}
  end

  defp parse_spec_([ head | tail ]) do
    [ pattern | args ] = head |> String.split(@argument_separator)

    n_args = args |> length

    if n_args > 1 do
      {:error, "Too many arguments in lemmatization spec: #{head}"}
    else
      wrap parse_spec_(tail), handle: fn parsed_items ->
        wrapn pattern |> String.replace("*", "[^\\s]*") |> Regex.compile, handle: fn pattern ->
          [
            {
              pattern,
              case n_args do
                0 -> nil
                1 -> args |> Enum.at(0) |> Integer.parse |> elem(0)
              end
            } | parsed_items
          ]
        end
      end
    end
  end

  @spec parse_spec(String.t()) :: tuple
  def parse_spec(spec) do
    @spaces |> Regex.split(spec) |> parse_spec_
    # for x <- @spaces |> Regex.split(spec) do
    #   [pattern | index] = x |> String.split("@")

    #   {
    #     pattern,
    #     case index |> length do
    #       0 -> k
    #   }
    # end
  end

  defp lemmatize_token_spec([], _spec, _indices, _all_spec, result, _engine) do
    {:ok, result}
  end

  defp lemmatize_token_spec([ token | tail ], [], indices, all_spec, result, engine) do
    lemmatize_token_spec(tail, all_spec, indices, all_spec, [ token | result ], engine)
  end

  defp lemmatize_token_spec(tokens, [ { pattern, index } | tail ], indices, all_spec, result, engine) do
    [ token | token_tail ] = tokens

    if Regex.match?(pattern, Keyword.get(token, :word)) do
      next_index = Map.get(indices, pattern, 0) + 1

      if index == nil || next_index == index do
        wrapn(
          case @debug do
            true -> Lemmat.parse(engine, Keyword.get(token, :word))
            false -> Lemma.parse(engine, Keyword.get(token, :word))
          end,
          handle: fn lemma ->
            lemmatize_token_spec(
              token_tail, all_spec, Map.put(indices, pattern, next_index), all_spec, 
              [
                [
                  word: lemma,
                  sep: Keyword.get(token, :sep)
                ] | result
              ], engine
            )
          end
        )
      else
        lemmatize_token_spec(token_tail, all_spec, Map.put(indices, pattern, next_index), all_spec, [ token | result ], engine)
      end

    else
      lemmatize_token_spec(tokens, tail, indices, all_spec, result, engine)
    end
  end

  # defp lemmatize_token(tokens, spec, indices) do
  #   lemmatize_token_spec(tokens, spec, %{}, spec, [])
  # end

  def lemmatize(spec, tokens) do
    engine = case @debug do
      true -> nil
      false -> :en |> Lemma.new
    end

    wrap lemmatize_token_spec(tokens, spec, %{}, spec, [], engine), handle: fn tokens ->
      Llist.reverse tokens
    end
    # indices = %{}

    # for token <- tokens do
    #   for {pattern, index} <- spec do
    #     word = Keyword.get(token, :word)

    #     if Regex.match?(pattern, word) do
    #       Map.put(indices, pattern, Map.get(indices, pattern, 0) + 1)
    #     end
    #   end
    # end

    # indices
  end
end
