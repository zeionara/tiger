defmodule Trello do
  @api_key System.get_env("TRELLO_KEY")
  @api_token System.get_env("TRELLO_TOKEN")
  @api_version "1"

  @base "https://api.trello.com/#{@api_version}"
  @auth "key=#{@api_key}&token=#{@api_token}"

  def get_board(id) do
    Http.get("#{@base}/boards/#{id}?#{@auth}")
  end
end
