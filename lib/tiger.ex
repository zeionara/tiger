defmodule Tiger do
  @moduledoc """
  Documentation for `Tiger`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Tiger.hello()
      :world

  """
  def create_card(board, list, name, opts \\ []) do
    case Trello.get_lists(board) do
      {:ok, body} -> 
        lists = body |> Enum.filter(fn(x) -> x["name"] == list end)
        case lists |> length do
          1 ->
            [head | _] = lists
            {:ok, head}
          n -> {:error, "There are #{n} lists with name #{list}. Must be exactly one"}
        end
      error -> error
    end |> case do
      {:ok, list} -> Trello.create_card(list["id"], name, opts)
      error -> error
    end
  end
end
