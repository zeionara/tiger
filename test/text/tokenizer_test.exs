defmodule Tiger.Text.TokenizerTest do
  use ExUnit.Case

  import Tiger.Text.Tokenizer, only: [split: 1, join: 1]
  import Tiger.Error, only: [set: 2]

  alias Tiger.Text.Token, as: Token

  test "empty string" do
    assert split("") == {:ok, []}
  end

  test "string with spaces" do
    assert split("  ") == {:ok, [
      %Token{raw: nil, sep: "  "}
    ]}
  end

  test "string with one token surrounded by spaces" do
    assert split("  foo  ") == {:ok, [
      %Token{raw: nil, sep: "  "},
      %Token{raw: "foo", sep: "  "}
    ]}
  end

  test "string with multiple tokens" do
    assert split("foo  bar Baz  ") == {:ok, [
      %Token{raw: "foo", sep: "  "},
      %Token{raw: "bar", sep: " "},
      %Token{raw: "Baz", sep: "  "}
    ]}
  end

  test "string with tokens and punctuation" do
    assert split("Lorem ipsum. Dolor sit amet?") == {:ok, [
      %Token{raw: "Lorem", sep: " "},
      %Token{raw: "ipsum", sep: nil},
      %Token{raw: ".", sep: " "},
      %Token{raw: "Dolor", sep: " "},
      %Token{raw: "sit", sep: " "},
      %Token{raw: "amet", sep: nil},
      %Token{raw: "?", sep: nil}
    ]}
  end

  test "multiple punctuation marks in a raw" do
    assert split("what?  ? that's...") == {:ok, [
      %Token{raw: "what", sep: nil},
      %Token{raw: "?", sep: "  "},
      %Token{raw: "?", sep: " "},
      %Token{raw: "that", sep: nil},
      %Token{raw: "'", sep: nil},
      %Token{raw: "s", sep: nil},
      %Token{raw: ".", sep: nil},
      %Token{raw: ".", sep: nil},
      %Token{raw: ".", sep: nil}
    ]}
  end

  test "joining" do
    source = "what?  ? that's..."

    set tokens: source |> split do
      assert tokens |> join == source
    end
  end
end
