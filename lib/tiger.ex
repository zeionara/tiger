defmodule Tiger do
  import Opts, only: [flag: 1]

  @moduledoc """
  Documentation for `Tiger`.
  """

  defp get_member_ids([], _opts) do
    {:ok, []}
  end

  defp get_member_ids([ head | tail], opts) do
    flag :skip
    # skip = Keyword.get(opts, :skip, false)

    case Trello.get_member(head) do
      {:ok, member} ->
        case tail do
          [] -> {:ok, [ member["id"] ]}
          _ -> 
            case get_member_ids(tail, opts) do
              {:error, message} -> {:error, message}
              # {:ok, ids} -> {:ok, "#{member["id"]},#{ids}"}
              {:ok, ids} -> {:ok, [ member["id"] | ids ]}
            end
        end
      {:error, _} ->
        if skip do
          case get_member_ids(tail, opts) do
            {:error, message} -> {:error, message}
            # {:ok, ids} -> {:ok, "#{member["id"]},#{ids}"}
            {:ok, ids} -> {:ok, ids}
          end
        else
          {:error, "Incorrect member #{head}"}
        end
    end
  end

  defp get_label_ids(names, name_to_id) do
    names
    |> Concurrency.pmap(&(name_to_id[&1]))
  end

  defp create_card(board, list, name, due, labels, members, opts) do
    case Trello.get_lists(board) do
      {:ok, body} -> 
        lists = body |> Enum.filter(
          fn(x) ->
            case x["name"] |> Formatter.to_kebab_case do
              {:ok, string} -> string == list
              # _ -> false
            end
          end
        )
        case lists |> length do
          1 ->
            [head | _] = lists
            {:ok, head}
          n -> {:error, "There are #{n} lists with name #{list}. Must be exactly one"}
        end
      error -> error
    end |> case do
      {:ok, list} -> Trello.create_card(list["id"], name, opts |> Keyword.merge([ due: due, members: members, labels: labels, due: Keyword.get(opts, :done, false) ]))
      error -> error
    end
  end

  defp create_card(board, list, name, due, labels, opts) do
    case Keyword.get(opts, :members) do
      nil -> {:ok, nil}
      members -> get_member_ids(members, opts)
    end |> case do
      {:error, message} -> {:error, message}
      {:ok, members} -> create_card(board, list, name, due, labels, members, opts)
    end
  end

  defp create_card(board, list, name, due, opts) do
    # skip = Keyword.get(opts, :skip, false)
    flag :skip

    case Keyword.get(opts, :labels) do
      nil -> create_card(board, list, name, due, nil, opts)
      labels ->
        case Trello.list_labels(board) do
          {:error, message } -> {:error, message}
          {:ok, response} ->
            name_to_id =
              response
              |> Concurrency.pmap(fn entry -> {entry["name"], entry["id"]} end)
              |> Map.new
            ids = labels |> get_label_ids(name_to_id)
            if !skip and Enum.member?(ids, nil) do
              {:error, "Passed unknown labels: #{labels |> Enum.join(",")}"}
            else
              create_card(
                board,
                list,
                name,
                due,
                if Enum.member?(ids, nil) do
                  ids |> Enum.filter(& !is_nil(&1))
                else
                  ids
                end,
                opts
              )
            end
        end
    end
  end

  @doc """
  Create trello card

  ## Examples

      iex> Tiger.create_card("foo", "bar", "baz")
      {:ok, "fjidjfiejfowjief"}

  """

  def create_card(board, list, name, opts \\ []) do
    create_card(board, list, name, Keyword.get(opts, :due), opts)
    # case Keyword.get(opts, :due) do
    #   nil -> create_card(board, list, name, nil, opts)
    #   due -> create_card(board, list, name, due, opts)
    # end
  end
end
