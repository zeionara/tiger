defmodule Tiger.Text.LemmatizerWrapperTest do
  use ExUnit.Case

  alias Tiger.Text.Lemmatizer.Wrapper, as: Wrapper

  setup_all do
    {:ok, engine: Wrapper.new}
  end

  test "simple regular word", %{engine: engine} do
    assert engine |> Wrapper.parse("added") == {:ok, "add"}
  end

  test "difficult regular word", %{engine: engine} do
    assert engine |> Wrapper.parse("refactored") == {:ok, "refactor"} 
  end

  test "simple irregular word", %{engine: engine} do
    assert engine |> Wrapper.parse("felt") == {:ok, "feel"} 
  end

  test "difficult irregular word", %{engine: engine} do
    assert engine |> Wrapper.parse("went") == {:ok, "we"} # lemmatizer gives incorrect answer
  end

  test "ambiguous", %{engine: engine} do
    assert engine |> Wrapper.parse("better") == {:ok, "wet"} # lemmatizer gives multiple possible answers, which are all incorrect
  end
end
