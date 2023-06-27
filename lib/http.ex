defmodule Http do
  @moduledoc """
  Basic http methods for working with rest apis
  """

  defp push_params(url, params) do
    "#{url}?#{URI.encode_query(params)}"
  end

  def get(url, opts \\ []) do
    params = Keyword.get(opts, :params, %{})

    %{status_code: code, body: body} = url |> push_params(params) |> HTTPoison.get!

    case code do
      200 -> {:ok, Poison.decode!(body)}
      _ -> {:error, "Invalid response code: #{code}"}
    end
  end

  def post(url, opts \\ []) do
    params = Keyword.get(opts, :params, %{})
    body = Keyword.get(opts, :body, %{})

    %{status_code: code, body: body} = url |> push_params(params) |> HTTPoison.post!(body |> Poison.encode!)

    case code do
      200 -> {:ok, Poison.decode!(body)}
      _ -> {:error, Poison.decode!(body)}
    end
  end
end
