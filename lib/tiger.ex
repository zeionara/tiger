defmodule Tiger do
  @moduledoc """
  Documentation for `Tiger`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Tiger.hello()
      :world

  """
  def talk do
    Https.get('foo.bar')
    :meow
  end
end
