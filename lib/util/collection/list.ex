defimpl Tiger.Util.Collection, for: List do
  import Tiger.Opt, only: [opt: 1]

  @sep " "

  # get

  def first([ head | _ ]) do
    head
  end

  def second([ _ | [ next | _ ]]) do
    next
  end

  def third([ _ | [ _ | [ next | _ ]]]) do
    next
  end

  def last([ head | [] ]) do
    head
  end

  def last([ _ | tail ]) do
    last(tail)
  end

  # reverse

  def reverse([], previous_nodes) do
    previous_nodes
  end

  def reverse([ head | tail ], previous_nodes) do
    reverse(tail, [ head | previous_nodes ])
  end

  def reverse([]) do
    []
  end

  def reverse([ head | tail ]) do
    reverse(tail, [ head ])
  end

  # join

  defp _join([], _sep) do
    ""
  end

  defp _join([ head | tail ], sep) do
    "#{sep}#{head}#{_join(tail, sep)}"
  end

  def join(items, sep \\ @sep)

  def join([ head | tail ], sep) do
    "#{head}#{_join(tail, sep)}"
  end

  def join([], _sep) do
    ""
  end

  # chain

  def chain([ lhs_head | [] ], rhs) do
    [ lhs_head | rhs ]
  end

  def chain([ lhs_head | lhs_tail ], rhs) do
    [ lhs_head | chain(lhs_tail, rhs) ]
  end

  def chain([], rhs) do
    rhs
  end

  # transform

  defp filter([ head | tail ], opts) do
    case opt :filter do
      nil -> 
        [ head | transform(tail, opts) ]
      filter ->
        if filter.(head) do
          [ head | transform(tail, opts) ]
        else
          transform(tail, opts)
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
      nil -> filter([ head | tail ], opts)
      split ->
        items = split.(head)

        if length(items) < 2 do
          filter([ head | tail ], opts)
        else
          items |> chain(tail) |> filter(opts)
        end
    end
  end

  # drop

  def drop_last([ _head | [] ]) do
    []
  end

  def drop_last([ head | tail ]) do
    [head | drop_last(tail)]
  end

  def drop_last([]) do
    []
  end
end
