defmodule Trello do
  @api_key System.get_env("TRELLO_KEY")
  @api_token System.get_env("TRELLO_TOKEN")
  @api_version "1"

  @base "https://api.trello.com/#{@api_version}"
  @auth "key=#{@api_key}&token=#{@api_token}"

  def get_board(id) do
    Http.get("#{@base}/boards/#{id}?#{@auth}")
  end

  def get_lists(board) do
    Http.get("#{@base}/boards/#{board}/lists?#{@auth}")
  end

  def create_card(list: list, name: name) do
    Http.post("#{@base}/cards/?idList=#{list}&#{@auth}", params: %{"name" => name, "desc" => "#{name} description"})
  end
end
