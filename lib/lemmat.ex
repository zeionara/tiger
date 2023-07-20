defmodule Lemmat do
  def parse(_engine, word) do
    {:ok, "#{word |> String.slice(0..-3)}##"}
  end
end
