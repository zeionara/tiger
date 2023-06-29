defmodule Concurrency do
  def pmap(items, func) do
    items
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end
end
