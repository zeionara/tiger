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

  def merge([ lhs_head | [] ], rhs) do
    [ lhs_head | rhs ]
  end

  def merge([], rhs) do
    rhs
  end

  def merge([ lhs_head | lhs_tail ], rhs) do
    [ lhs_head | merge(lhs_tail, rhs) ]
  end
end
