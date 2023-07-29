defmodule Tiger.Text.Spec.Parser do
  import Tiger.Error, only: [get: 2, set: 2]

  import Tiger.Util.String, only: [ss: 1]
  import Tiger.Util.Collection, only: [first: 1]

  alias Tiger.Text.Token.Template, as: Template
  alias Tiger.Text.Spec, as: Spec

  @argument_separator "@"

  defp parse_([]) do
    {:ok, []}
  end

  defp parse_([ head | tail ]) do
    [ shape | args ] = head |> String.split(@argument_separator)

    n_args = args |> length

    if n_args > 1 do
      {:error, {:too_many_arguments_in_token_template_definition, head}}
    else
      get templates: parse_(tail) do
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

  def parse(templates) do
    set templates: templates |> ss |> parse_ do
      Spec.init(templates)
    end
  end
end
