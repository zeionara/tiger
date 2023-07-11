defmodule Llist do
  import Opts, only: [opt: 1]

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

  def transform_([ head | tail ], opts \\ []) do
    case opt :filter do
      nil -> 
        [ head | transform(tail, opts) ]
        # case opt :map do
        #   nil -> [ head | transform(tail) ]
        #   map -> [ map.(head) | transform(tail, [map: map]) ]
        # end
      filter -> if filter.(head) do
        [ head | transform(tail, opts) ]
        # case opt :map do
        #   nil -> [ head | transform(tail, [filter: filter]) ]
        #   map -> [ map.(head) | transform(tail, [map: map, filter: filter]) ]
        # end
      else
        transform(tail, opts)
        # case opt :map do
        #   nil -> transform(tail, [filter: filter])
        #   map -> transform(tail, [map: map, filter: filter])
        # end
      end
    end
  end

  def transform(items, opts \\ [])

  def transform([], _opts) do
    []
  end

  def transform([ head | tail ], opts) do
    head = case opt :map do
      nil -> head
      map -> map.(head)
    end

    case opt :split do
      nil -> transform_([ head | tail ], opts)
      split ->
        items = split.(head)

        if length(items) < 2 do
          transform_([ head | tail ], opts)
        else
          transform_(merge(items, tail), opts)
        end
    end
  end
end
