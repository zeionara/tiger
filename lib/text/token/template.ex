defmodule Tiger.Text.Token.Template do
  defstruct [:shape, :index]

  import Tiger.Error, only: [get: 2]

  def compile(shape, index) do
    get shape: "^#{shape |> String.replace("*", "[^\\s]*")}$" |> Regex.compile do
      %Tiger.Text.Token.Template{
        shape: shape,
        index: index
      }
    end
  end

  # def shape_match?(%Tiger.Text.Token.Template{shape: shape}, %Tiger.Text.Token{raw: raw}) do
  #   shape == nil || Regex.match?(shape, raw)
  # end

  def shape_match?(shape, raw) do
    shape == nil || Regex.match?(shape, raw)
  end

  def index_match?(%Tiger.Text.Token.Template{index: index}, token_index) do
    index == nil || index == token_index
  end
end
