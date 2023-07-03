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

  def join(items, sep \\ " ")

  defp _join([], sep) do
    ""
  end

  defp _join([ head | tail ], sep) do
    "#{sep}#{head}#{_join(tail, sep)}"
  end

  def join([ head | tail ], sep) do
    "#{head}#{_join(tail, sep)}"
  end

  def join([], sep) do
    ""
  end
end
