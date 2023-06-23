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
  def talk(board) do
    # Http.get('foo.bar')
    Trello.get_board(board)
  end
end
