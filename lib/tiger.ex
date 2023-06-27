defmodule Tiger do
  @moduledoc """
  Documentation for `Tiger`.
  """

  defp get_member_ids([ head | tail]) do
    case Trello.get_member(head) do
      {:ok, member} ->
        case tail do
          [] -> {:ok, [ member["id"] ]}
          _ -> 
            case get_member_ids(tail) do
              {:error, message} -> {:error, message}
              # {:ok, ids} -> {:ok, "#{member["id"]},#{ids}"}
              {:ok, ids} -> {:ok, [ member["id"] | ids ]}
            end
        end
      {:error, _} -> {:error, "Incorrect member #{head}"}
    end
  end

  @doc """
  Create trello card

  ## Examples

      iex> Tiger.create_card("foo", "bar", "baz")
      {:ok, "fjidjfiejfowjief"}

  """

  def create_card(board, list, name, opts \\ []) do
    case Keyword.get(opts, :members) do
      nil -> {:ok, nil}
      members -> get_member_ids(members)
    end |> case do
      {:error, message} -> {:error, message}
      {:ok, members} ->
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
          {:ok, list} -> Trello.create_card(list["id"], name, opts |> Keyword.merge([ members: members ]))
          error -> error
        end
    end
      # members -> members |> Enum.map(
      #     fn member ->
      #       case Trello.get_member("zeionara") do
      #         {:ok, member} -> member["id"]
      #         {:error, _} -> {:error, "can't get info about member #{member}"}
      #       end
  end
end
