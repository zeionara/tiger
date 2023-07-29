# defmodule Tiger.Util.Tuple do
#   def first(items) do
#     items |> elem(0)
#   end
# 
#   def second(items) do
#     items |> elem(1)
#   end
# 
#   def third(items) do
#     items |> elem(2)
#   end
# end

defimpl Tiger.Util.Collection, for: Tuple do
  def first(items) do
    items |> elem(0)
  end

  def second(items) do
    items |> elem(1)
  end

  def third(items) do
    items |> elem(2)
  end

  def last(items) do
    elem(items, tuple_size(items) - 1)
  end

  def reverse(_items) do
    raise "Not implemented"
  end

  def join(_items) do
    raise "Not implemented"
  end

  def join(_items, _sep) do
    raise "Not implemented"
  end

  def chain(_lhs, _rhs) do
    raise "Not implemented"
  end

  def transform(_items, _opts) do
    raise "Not implemented"
  end

  def drop_last(_items) do
    raise "Not implemented"
  end
end
