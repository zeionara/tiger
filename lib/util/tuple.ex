defmodule Tiger.Util.Tuple do
  def first(items) do
    items |> elem(0)
  end

  def second(items) do
    items |> elem(1)
  end

  def third(items) do
    items |> elem(2)
  end
end
