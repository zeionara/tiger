defmodule Trello do
  @api_key System.get_env("TRELLO_KEY")
  @api_token System.get_env("TRELLO_TOKEN")
  @api_version "1"

  @root "https://api.trello.com/#{@api_version}"
  @auth %{ "key" => @api_key, "token" => @api_token } # "key=#{@api_key}&token=#{@api_token}"

  defp get(url, opts \\ []) do
    case Keyword.get(opts, :params) do
      nil -> Http.get(url, params: @auth)
      params -> Http.get(url, params: Map.merge(@auth, params))
    end
  end

  # defp post(url, opts \\ []) do
  defp post(url, opts) do
    case Keyword.get(opts, :params) do
      nil ->
        case Keyword.get(opts, :body) do
          nil -> Http.post(url, params: @auth)
          body -> Http.post(url, params: @auth, body: body)
        end
      params ->
        params = Map.merge(@auth, params)

        case Keyword.get(opts, :body) do
          nil -> Http.post(url, params: params)
          body -> Http.post(url, params: params, body: body)
        end
    end
  end

  def get_board(id) do
    get("#{@root}/boards/#{id}")
  end

  def get_lists(board) do
    get("#{@root}/boards/#{board}/lists")
  end

  def list_labels(board) do
    get("#{@root}/boards/#{board}/labels", params: %{ "fields" => "id,name" })
  end

  def create_card(list, name, opts \\ []) do
    verbose = Keyword.get(opts, :verbose, false)

    params = %{"idList" => list, "name" => name, "desc" => opts |> Keyword.get(:description, "#{name} description")}

    params = case Keyword.get(opts, :members) do
      nil -> params
      members -> params |> Map.put("idMembers", members |> Formatter.join_list)
    end

    params = case Keyword.get(opts, :labels) do
      nil -> params
      labels -> params |> Map.put("idLabels", labels |> Formatter.join_list)
    end

    params = case Keyword.get(opts, :due) do
      nil -> params
      value -> params |> Map.put("due", value |> Formatter.encode_date)
    end

    params = if Keyword.get(opts, :done, false) do
      params |> Map.put("dueComplete", true)
    else
      params
    end

    response = post("#{@root}/cards", params: params)

    case verbose do
      true -> response
      false ->
        case response do
          {:ok, card} -> {:ok, card["id"]}
          {:error, _} -> {:error, "failed to create card"}
        end
    end
  end

  def get_member(id) do
    get("#{@root}/members/#{id}")
  end
end
