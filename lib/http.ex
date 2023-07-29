defmodule Http do
  @moduledoc """
  Basic http methods for working with rest apis
  """

  import Tiger.Opt, only: [opt: 2]

  defp push_params(url, params) do
    "#{url}?#{URI.encode_query(params)}"
  end

  defp handle_code(code, body) do
    case code do
      200 -> {:ok, Poison.decode!(body)}
      _ -> {:error, Poison.decode!(body)}
    end
  end

  def get(url, opts \\ []) do
    params = opt :params, default: %{}

    %{status_code: code, body: body} = url |> push_params(params) |> HTTPoison.get!

    handle_code(code, body)
  end

  def post(url, opts \\ []) do
    params = opt :params, default: %{}
    body = opt :body, default: %{}

    %{status_code: code, body: body} = url |> push_params(params) |> HTTPoison.post!(body |> Poison.encode!)

    handle_code(code, body)
  end

  def put(url, opts \\ []) do
    params = opt :params, default: %{}
    body = opt :body, default: %{}

    %{status_code: code, body: body} = url |> push_params(params) |> HTTPoison.put!(body |> Poison.encode!)

    handle_code(code, body)
  end
end
