defmodule Tiger.Text.Lemmatizer.SpecTest do
  use ExUnit.Case

  alias Tiger.Text.Lemmatizer.Spec, as: Lemmatizer
  alias Tiger.Text.Token.Spec, as: Spec
  alias Tiger.Text.Tokenizer, as: Tokenizer

  import Tiger.Error

  test "single token" do
    # wrap Spec.init("fo.") do
    #   IO.inspect val
    # end

    get tokens: Tokenizer.split("foo bar") do
      get spec: Spec.init("fo.") do
        get lemmas: Lemmatizer.apply(spec, tokens, debug: true) do
          assert Tokenizer.join(lemmas) == "f## bar"
        end
      end
    end
  end
end
