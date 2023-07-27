defmodule Tiger.Command.Argument.SpaceSeparated.ParserTest do
  use ExUnit.Case

  import Tiger.Command.Argument.SpaceSeparated.Parser, only: [find_all: 1]
  alias Tiger.Command.Argument.SpaceSeparated.Struct, as: Arg

  test "no space separated arguments" do
    assert find_all("foo bar") == {:ok, []}
  end

  test "one argument" do
    assert find_all("foo ^& bar ^&") == {:ok, [%Arg{occurrence: "^& bar ^&", value: " bar "}]}
  end

  test "two arguments" do
    assert find_all("foo ^& bar ^& baz ^&qux qUuX  ^&") == {:ok, [
      %Arg{occurrence: "^& bar ^&", value: " bar "},
      %Arg{occurrence: "^&qux qUuX  ^&", value: "qux qUuX  "}
    ]}
  end

  test "one redundant mark at the very end" do
    assert find_all("foo ^& bar ^& ^&") |> elem(0) == :error
  end

  test "one redundant mark in the middle of the text" do
    assert find_all("foo ^& bar ^& ^& baz qux quux") |> elem(0) == :error
  end
end
