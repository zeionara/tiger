defmodule Tiger.Text.Lemmatizer.Spec do
  import Opts, only: [flag: 1]

  alias Tiger.Text.Token.Template, as: Template
  alias Tiger.Text.Token, as: Token
  alias Tiger.Text.Token.Spec, as: Spec

  alias Tiger.Text.Lemmatizer.Spec, as: Self
  alias Tiger.Text.Lemmatizer.Wrapper, as: Wrapper

  defstruct [shape_indices: %{}, remaining_templates: nil, all_templates: nil, engine: nil]

  import Error, only: [wrap: 2, wrapn: 2]

  defp lemmatize([], _state, _opts) do
    {:ok, []}
  end

  defp lemmatize([ token | tail ], %Self{remaining_templates: [], all_templates: templates, shape_indices: indices, engine: engine}, opts) do
    wrap lemmatize(tail, %Self{remaining_templates: templates, all_templates: templates, shape_indices: indices, engine: engine}, opts), handle: fn result ->
      [ token | result ]
    end
  end

  defp lemmatize(
    tokens = [token = %Token{raw: raw, sep: sep} | token_tail],
    %Self{remaining_templates: [ template = %Template{shape: shape} | tail ], all_templates: all_templates, shape_indices: indices, engine: engine},
    opts
  ) do
    if template |> Template.shape_match?(token) do # check that shape matches
      next_index = Map.get(indices, shape, 0) + 1

      if template |> Template.index_match?(next_index) do # check that index matches
        wrap Wrapper.parse(engine, raw, opts), handle: fn lemma ->
          wrapn lemmatize(
            token_tail,
            %Self{remaining_templates: all_templates, all_templates: all_templates, shape_indices: Map.put(indices, shape, next_index), engine: engine},
            opts
          ), handle: fn result ->
            [
              %Token{raw: lemma, sep: sep} | result
            ]
          end
        end
      else
        lemmatize(
          tokens,
          %Self{remaining_templates: tail, all_templates: all_templates, shape_indices: Map.put(indices, shape, next_index), engine: engine},
          opts
        )
      end

    else
      lemmatize(
        tokens,
        %Self{remaining_templates: tail, all_templates: all_templates, shape_indices: indices, engine: engine},
        opts
      )
    end
  end

  def apply(%Spec{templates: templates}, tokens, opts \\ [debug: false]) do
    flag :debug

    lemmatize(tokens,
      %Self{
        remaining_templates: templates, all_templates: templates,
        engine: (if debug, do: nil, else: Wrapper.new)
      }, opts
    )
  end
end
