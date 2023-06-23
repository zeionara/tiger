defmodule Http do
  @moduledoc """
  Basic http methods for working with rest apis
  """

  def get(url) do
    %{status_code: code, body: body} = HTTPoison.get!(url)

    case code do
      200 -> {:ok, Poison.decode!(body)}
      _ -> {:error, "Invalid response code: #{code}"}
    end
  end

  def post(url, opts \\ []) do
    params = Keyword.get(opts, :params, %{})
    body = Keyword.get(opts, :body, %{})

    %{status_code: code, body: body} = HTTPoison.post!("#{url}&#{URI.encode_query(params)}", body |> Poison.encode!)

    case code do
      200 -> {:ok, Poison.decode!(body)}
      _ -> {:error, Poison.decode!(body)}
    end
  end
end
