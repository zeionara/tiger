defmodule TigerTest do
  use ExUnit.Case
  doctest Tiger

  test "greets the world" do
    assert Tiger.hello() == :world
  end
end
