defmodule Tiger do
  import Tiger.Opt, only: [deff: 1, flag: 1, opt: 1]
  import Error, only: [wrap: 2, wrapn: 2]

  @debug true

  @open_list System.get_env("TRELLO_OPEN_LIST")
  @close_list System.get_env("TRELLO_CLOSE_LIST")

  @moduledoc """
  Documentation for `Tiger`.
  """

  defp get_member_ids([], _opts) do
    {:ok, []}
  end

  defp get_member_ids([ head | tail], opts) do
    deff :skip
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

  defp get_list_id(board, list) do
    wrap Trello.get_lists(board), handle: fn (body) ->
      lists = body |> Enum.filter(
        fn(x) ->
          case x["name"] |> Formatter.to_kebab_case do
            {:ok, string} -> string == list
          end
        end
      )
      case lists |> length do
        1 ->
          [head | _] = lists
          head
        n -> {:error, "There are #{n} lists with name #{list}. Must be exactly one"}
      end
    end 
  end

  defp create_card(board, list, name, due, labels, members, opts) do
    get_list_id(board, list) |> case do
      {:ok, list} -> Trello.create_card(list["id"], name, opts |> Keyword.merge([
        due: due,
        members: members,
        labels: labels,
        due: flag(:done),
        zoom: flag(:zoom)
      ]))
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
    deff :skip

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
    # IO.inspect opt
    if @debug do
      # IO.puts "board: #{board}, list: #{list}, name: #{name}"
      # opts |> IO.inspect
      # create_card(board, list, name, Keyword.get(opts, :due), opts)
      # :lemmatization_spec |> opt |> Lemmatizer.parse_spec |> IO.inspect
    else
      create_card(board, list, name, Keyword.get(opts, :due), opts)
    end
    # case Keyword.get(opts, :due) do
    #   nil -> create_card(board, list, name, nil, opts)
    #   due -> create_card(board, list, name, due, opts)
    # end
  end

  def close_card(board, signature, opts \\ []) do
    if @debug do
      {:ok, "Closed #{signature} with labels #{opt :labels}"}
    else
      wrapn get_list_id(board, @open_list), handle: fn list ->
        wrapn Trello.list_cards(list["id"]), handle: fn cards ->
          cards = cards |> Enum.filter(
            fn x ->
              signature_matches = x["desc"] |> String.contains?(signature)

              labels_match = case opt :labels do
                nil -> true
                reference_labels ->
                  labels = x["labels"] |> Enum.map(fn x -> x["name"] end)

                  Enum.all?(labels, fn x -> x in reference_labels end)
              end

              signature_matches and labels_match
            end
          )
          case length(cards) do
            0 -> {:error, "No cards with signature #{signature}"}
            1 ->
              [head | _ ] = cards
              card = head["id"]

              wrapn get_list_id(board, @close_list), handle: fn list ->
                Trello.move(card, list["id"], Tiger.Util.Collection.chain(opts, [done: true]))
              end
            _ -> {:error, "Too many cards with signature #{signature}"}
          end
        end
      end
    end
  end
end
