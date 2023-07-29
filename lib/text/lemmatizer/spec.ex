defmodule Tiger.Text.Lemmatizer.Spec do
  import Tiger.Opt, only: [deff: 1]

  alias Tiger.Text.Token.Template, as: Template
  alias Tiger.Text.Token, as: Token
  alias Tiger.Text.Spec, as: Spec

  alias Tiger.Text.Lemmatizer.Spec, as: Self
  alias Tiger.Text.Lemmatizer.Wrapper, as: Wrapper

  defstruct [shape_indices: %{}, handled_shapes: %{}, remaining_templates: nil, all_templates: nil, engine: nil, lemmatized: false]

  import Error, only: [wrap: 2, wrapn: 2]
  import Tiger.Error, only: [get: 2]

  # defp increment_indices(%Token{raw: raw}, indices) do
  #   Enum.map(indices, fn {shape, index} ->
  #     if shape |> Template.shape_match?(raw) do
  #       {shape, index + 1}
  #     else
  #       {shape, index}
  #     end
  #   end) |> Map.new
  # end

  defp lemmatize([], _state, _opts) do
    {:ok, []}
  end

  defp lemmatize([ token | tail ], %Self{remaining_templates: [], all_templates: templates, shape_indices: indices, engine: engine, lemmatized: lemmatized}, opts) do # when compared the token to every template
    get lemmas: lemmatize(tail, %Self{remaining_templates: templates, all_templates: templates, shape_indices: indices, engine: engine}, opts) do
      if lemmatized do
        lemmas
      else
        [ token | lemmas ]
      end
    end
  end

  defp lemmatize(
    tokens = [_token = %Token{raw: raw, sep: sep} | _token_tail],
    %Self{remaining_templates: [ template = %Template{shape: shape} | tail ], all_templates: all_templates, shape_indices: indices, handled_shapes: shapes, engine: engine, lemmatized: lemmatized},
    opts
  ) do
    # IO.inspect {token, template, indices}

    if shape |> Template.shape_match?(raw) do # check that shape matches
      index = case Map.get(indices, shape) do
        nil -> 1
        index ->
          case Map.get(shapes, shape) do
            nil -> index # if current token has not been compared to this shape earlier, then next index is taken without changes
            _ -> index - 1 # if current token has been compared to this shape earlier, then next index must be transformed back to current index
          end
      end

      # {indices, next_index} = case Map.get(indices, shape) do
      #   nil -> {Map.put(indices, shape, 0), 1}
      #   index -> {indices, index + 1}
      # end

      # IO.inspect index

      if !lemmatized && template |> Template.index_match?(index) do # check that index matches
        wrap Wrapper.parse(engine, raw, opts), handle: fn lemma ->
          wrapn lemmatize(
            tokens,
            case Map.get(shapes, shape) do
              nil -> %Self{ # first occurrence of this shape for this token
                  remaining_templates: tail, all_templates: all_templates,
                  shape_indices: Map.put(indices, shape, index + 1), handled_shapes: Map.put(shapes, shape, true), engine: engine, lemmatized: true
              }
              _ -> %Self{
                  remaining_templates: tail, all_templates: all_templates, shape_indices: indices, handled_shapes: shapes, engine: engine, lemmatized: true
              }
            end,
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
          case Map.get(shapes, shape) do
            nil -> %Self{ # first occurrence of this shape for this token
                remaining_templates: tail, all_templates: all_templates,
                shape_indices: Map.put(indices, shape, index + 1), handled_shapes: Map.put(shapes, shape, true), engine: engine, lemmatized: lemmatized
            }
            _ -> %Self{
                remaining_templates: tail, all_templates: all_templates, shape_indices: indices, handled_shapes: shapes, engine: engine, lemmatized: lemmatized
            }
          end,
          # %Self{remaining_templates: tail, all_templates: all_templates, shape_indices: Map.put(indices, shape, next_index), engine: engine},
          # %Self{remaining_templates: tail, all_templates: all_templates, shape_indices: indices, engine: engine},
          opts
        )
      end
    else
      lemmatize(
        tokens,
        %Self{remaining_templates: tail, all_templates: all_templates, shape_indices: indices, handled_shapes: shapes, engine: engine, lemmatized: lemmatized},
        opts
      )
    end
  end

  def apply(%Spec{templates: templates}, tokens, opts \\ [debug: false]) do
    deff :debug

    lemmatize(tokens,
      %Self{
        remaining_templates: templates, all_templates: templates,
        engine: (if debug, do: nil, else: Wrapper.new)
      }, opts
    )
  end
end
