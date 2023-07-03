defmodule Llist do
  def reverse([], previous_nodes) do
    previous_nodes
  end

  def reverse([ head | tail ], previous_nodes) do
    reverse(tail, [ head | previous_nodes ])
  end

  def reverse([ head | tail ]) do
    reverse(tail, [ head ])
  end

  def reverse([]) do
    []
  end

  defp _join([], _sep) do
    ""
  end

  defp _join([ head | tail ], sep) do
    "#{sep}#{head}#{_join(tail, sep)}"
  end

  def join(items, sep \\ " ")

  def join([ head | tail ], sep) do
    "#{head}#{_join(tail, sep)}"
  end

  def join([], _sep) do
    ""
  end
end
