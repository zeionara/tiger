defmodule Lemmat do
  import Opts, only: [flag: 1]

  def parse(engine, word, opts \\ []) do
    flag :debug

    if debug do
      {:ok, "#{word |> String.slice(0..-3)}##"}
    else
      engine |> Lemma.parse(word)
    end
  end
end
