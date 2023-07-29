defmodule Tiger.Text.Lemmatizer.WrapperTest.Macro do
  alias Tiger.Text.Lemmatizer.Wrapper, as: Wrapper

  defmacro ensure(name, token: token, lemma: lemma) do
    quote do
      test unquote(name), %{engine: engine} do
        assert engine |> Wrapper.parse(unquote(token)) == {:ok, unquote(lemma)}
      end
    end
  end
end

defmodule Tiger.Text.Lemmatizer.WrapperTest do
  use ExUnit.Case

  import Tiger.Text.Lemmatizer.WrapperTest.Macro

  alias Tiger.Text.Lemmatizer.Wrapper, as: Wrapper

  setup_all do
    {:ok, engine: Wrapper.new}
  end

  ensure "simple regular word", token: "added", lemma: "add"
  ensure "difficult regular word", token: "refactored", lemma: "refactor" # lemmatizer doesn't now an answer, this value is obtained by guessing

  ensure "simple irregular word", token: "felt", lemma: "feel"
  ensure "difficult irregular word", token: "went", lemma: "we" # lemmatizer gives incorrect answer

  ensure "ambiguous", token: "better", lemma: "wet" # lemmatizer gives multiple possible answers, which are all incorrect
end
