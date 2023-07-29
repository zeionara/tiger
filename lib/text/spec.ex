defmodule Tiger.Text.Spec do
  defstruct [:templates]

  alias Tiger.Text.Token.Template, as: Template

  import Tiger.Util.String, only: [ss: 1]
  import Tiger.Util.Collection, only: [first: 1]

  import Tiger.Error, only: [get: 2, set: 2]

  @argument_separator "@"

  defp parse([]) do
    {:ok, []}
  end

  defp parse([ head | tail ]) do
    [ shape | args ] = head |> String.split(@argument_separator)

    n_args = args |> length

    if n_args > 1 do
      {:error, {:too_many_arguments_in_token_template_definition, head}}
    else
      get templates: parse(tail) do
        set template: Template.compile(
          shape,
          case n_args do
            0 -> nil
            1 -> args |> first |> Integer.parse |> first
          end
        ) do
          [ template | templates ]
        end
      end
    end
  end

  # @spec init(String.t()) :: %Tiger.Text.Token.Spec{}
  def init(spec) do
    get templates: spec |> ss |> parse do
      %Tiger.Text.Spec{
        templates: templates
      }
    end
  end
end
