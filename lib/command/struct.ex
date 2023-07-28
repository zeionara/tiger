defmodule Tiger.Command.Struct do
  import Tiger.Util.String, only: [ss: 1]
  import Llist, only: [transform: 2]

  alias Tiger.Command.Argument.SpaceSeparated.Normalizer, as: Ssan
  alias Tiger.Command.Argument.Mark, as: Am

  defstruct [:name, :args]

  defp build(name, args) do
    %Tiger.Command.Struct{name: name, args: args}
  end

  def init(name, args) do
    args = args |> ss |> transform(
      map: fn x ->
        x |> Am.drop_heading_mark |> Ssan.denormalize
      end,
      filter: fn x ->
        x != ""
      end
    )

    case { name, args } do
      { "create", [] } -> {:ok, build(:create, [])}
      { "create", [ lemmatization_spec ] } -> {:ok, build(:create, [lemmatization_spec])}
      { "close", [ symbol ] } -> {:ok, build(:close, [symbol])}
      { "make", [ title ] } -> {:ok, build(:make, [title])}
      { "make", [ title, description ] } -> {:ok, build(:make, [name: title |> String.trim, description: description |> String.trim])}

      _ -> {:error, "Unrecognized task #{name}"}
    end
  end
end
