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

  def create_card(list, name, opts \\ []) do
    verbose = Keyword.get(opts, :verbose, false)

    response = post("#{@root}/cards", params: %{"idList" => list, "name" => name, "desc" => "#{name} description"})

    case verbose do
      true -> response
      false ->
        case response do
          {:ok, card} -> {:ok, card["id"]}
          {:error, _} -> {:error, "failed to create card"}
        end
    end
  end
end
