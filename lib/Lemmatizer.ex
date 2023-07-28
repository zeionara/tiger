defmodule Lemmatizer do
  import Opts, only: [flag: 1]

  alias Tiger.Text.Token.Template, as: Template
  alias Tiger.Text.Token, as: Token

  defstruct [shape_indices: %{}, remaining_templates: nil, all_templates: nil, engine: nil]

  import Error, only: [wrap: 2, wrapn: 2]

  defp lemmatize_(tokens, state, opts \\ [])

  defp lemmatize_([], _state, _opts) do
    {:ok, []}
  end

  defp lemmatize_([ token | tail ], %Lemmatizer{remaining_templates: [], all_templates: templates, shape_indices: indices, engine: engine}, opts) do
    wrap lemmatize_(tail, %Lemmatizer{remaining_templates: templates, all_templates: templates, shape_indices: indices, engine: engine}, opts), handle: fn result ->
      [ token | result ]
    end
  end

  defp lemmatize_(
    tokens = [token = %Token{raw: raw, sep: sep} | token_tail],
    %Lemmatizer{remaining_templates: [ template = %Template{shape: shape} | tail ], all_templates: all_templates, shape_indices: indices, engine: engine},
    opts
  ) do
    # [ token | token_tail ] = tokens

    if template |> Template.shape_match?(token) do # check shape matches
      next_index = Map.get(indices, shape, 0) + 1

      if template |> Template.index_match?(next_index) do # check index matches
        IO.inspect {engine, raw, opts}
        IO.inspect Lemmat.parse(engine, raw, opts)
        wrap Lemmat.parse(engine, raw, opts), handle: fn lemma ->
          wrapn lemmatize_(
            token_tail,
            %Lemmatizer{remaining_templates: all_templates, all_templates: all_templates, shape_indices: Map.put(indices, shape, next_index), engine: engine},
            opts
          ), handle: fn result ->
            [
              %Token{raw: lemma, sep: sep} | result
            ]
          end
        end
      else
        lemmatize_(
          tokens,
          %Lemmatizer{remaining_templates: tail, all_templates: all_templates, shape_indices: Map.put(indices, shape, next_index), engine: engine},
          opts
        )
      end

    else
      lemmatize_(
        tokens,
        %Lemmatizer{remaining_templates: tail, all_templates: all_templates, shape_indices: indices, engine: engine},
        opts
      )
    end
  end

  def lemmatize(spec, tokens, opts \\ []) do
    flag :debug

    lemmatize_(tokens, %Lemmatizer{remaining_templates: spec, all_templates: spec, engine: (if debug, do: nil, else: Lemma.new(:en))}, opts)

    # wrap lemmatize_(tokens, %Lemmatizer{remaining_templates: spec, all_templates: spec, engine: (if debug, do: nil, else: Lemma.new(:en))}, opts), handle: fn tokens ->
    #   Llist.reverse tokens
    # end
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
