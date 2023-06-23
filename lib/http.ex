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
end
