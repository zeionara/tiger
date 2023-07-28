defmodule Tiger.Text.Token do
  import Tiger.Util.String, only: [rjoin: 1]

  defstruct [:raw, :sep]

  def init(raw, sep) do
    %Tiger.Text.Token{
      raw: (if raw == nil || length(raw) < 1, do: nil, else: raw |> rjoin),
      sep: (if sep == nil || length(sep) < 1, do: nil, else: sep |> rjoin)
    }
  end
end

defmodule Tiger.Text.Token.Template do
  defstruct [:shape, :index]

  import Error, only: [wrap: 2]

  def compile(shape, index) do
    wrap shape |> String.replace("*", "[^\\s]*") |> Regex.compile, handle: fn shape ->
      %Tiger.Text.Token.Template{
        shape: shape,
        index: index
      }
    end
  end
end

defmodule Tiger.Text.Token.Spec do
  defstruct [:templates]

  alias Tiger.Text.Token.Template, as: Template

  import Tiger.Util.String, only: [ss: 1]

  import Error, only: [wrap: 2, wrapn: 2]

  @argument_separator "@"

  defp parse([]) do
    {:ok, []}
  end

  defp parse([ head | tail ]) do
    [ shape | args ] = head |> String.split(@argument_separator)

    n_args = args |> length

    if n_args > 1 do
      {:error, "Too many arguments in token template definition: #{head}"}
    else
      wrap parse(tail), handle: fn templates ->
        wrapn Template.compile(
          shape,
          case n_args do
            0 -> nil
            1 -> args |> Tiger.Util.List.first |> Integer.parse |> Tiger.Util.Tuple.first # TODO: implement an interface
          end
        ), handle: fn template ->
          [ template | templates ]
        end
      end
    end
  end

  # @spec init(String.t()) :: %Tiger.Text.Token.Spec{}
  def init(spec) do
    wrap spec |> ss |> parse, handle: fn templates ->
      %Tiger.Text.Token.Spec{
        templates: templates
      }
    end
  end
end
