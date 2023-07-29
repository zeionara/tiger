defmodule Tiger.Text.Spec.State do
  defstruct [remaining_templates: nil, all_templates: nil, shape_indices: %{}, handled_shapes: %{}, transformed: false, transform: nil]
end

defmodule Tiger.Text.Spec do
  defstruct [:templates]

  # import Tiger.Opt, only: [deff: 1]
  import Tiger.Error, only: [get: 2, set: 2]

  alias Tiger.Text.Spec.State, as: State
  alias Tiger.Text.Token.Template, as: Template
  alias Tiger.Text.Token, as: Token
  alias Tiger.Text.Spec, as: Spec
  alias Tiger.Text, as: Text

  def init(templates) do
    %Tiger.Text.Spec{
      templates: templates
    }
  end

  defp apply_([], _state, _opts) do
    {:ok, []}
  end

  defp apply_(
    [ token | tail ],
    %State{remaining_templates: [], all_templates: templates, shape_indices: indices, transformed: transformed, transform: transform},
    opts
  ) do # when compared the token to every template
    set result: apply_(tail, %State{remaining_templates: templates, all_templates: templates, shape_indices: indices, transform: transform}, opts) do
      if transformed do
        result
      else
        [ token | result ]
      end
    end
  end

  defp apply_(
    tokens = [token = %Token{raw: raw} | _token_tail],
    %State{
      remaining_templates: [ template = %Template{shape: shape} | tail ],
      all_templates: all_templates, shape_indices: indices, handled_shapes: shapes, transformed: transformed, transform: transform
    },
    opts
  ) do
    if shape |> Template.shape_match?(raw) do # check that shape matches
      index = case Map.get(indices, shape) do
        nil -> 1
        index ->
          case Map.get(shapes, shape) do
            nil -> index # if current token has not been compared to this shape earlier, then next index is taken without changes
            _ -> index - 1 # if current token has been compared to this shape earlier, then next index must be transformed back to current index
          end
      end

      if !transformed && template |> Template.index_match?(index) do # check that index matches
        get transformation_result: transform.(token) do
          set result: apply_(
            tokens,
            case Map.get(shapes, shape) do
              nil -> %State{ # first occurrence of this shape for this token
                  remaining_templates: tail, all_templates: all_templates,
                  shape_indices: Map.put(indices, shape, index + 1), handled_shapes: Map.put(shapes, shape, true), transformed: true, transform: transform
              }
              _ -> %State{
                  remaining_templates: tail, all_templates: all_templates, shape_indices: indices, handled_shapes: shapes, transformed: true, transform: transform
              }
            end,
            opts
          ) do
            [
              transformation_result | result
            ]
          end
        end
      else
        apply_(
          tokens,
          case Map.get(shapes, shape) do
            nil -> %State{ # first occurrence of this shape for this token
                remaining_templates: tail, all_templates: all_templates,
                shape_indices: Map.put(indices, shape, index + 1), handled_shapes: Map.put(shapes, shape, true), transformed: transformed, transform: transform
            }
            _ -> %State{
                remaining_templates: tail, all_templates: all_templates, shape_indices: indices, handled_shapes: shapes, transformed: transformed, transform: transform
            }
          end,
          opts
        )
      end
    else
      apply_(
        tokens,
        %State{remaining_templates: tail, all_templates: all_templates, shape_indices: indices, handled_shapes: shapes, transformed: transformed, transform: transform},
        opts
      )
    end
  end

  def apply(%Spec{templates: templates}, %Text{tokens: tokens}, transform, opts \\ [debug: false]) do
    apply_(tokens, %State{remaining_templates: templates, all_templates: templates, transform: transform}, opts)
  end
end
