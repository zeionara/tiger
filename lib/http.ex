defmodule Https do
  @moduledoc """
  Basic http methods for working with rest apis
  """

  def get(url) do
    IO.puts('fetching #{url}')
    :data
  end
end
