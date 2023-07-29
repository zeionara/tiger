defmodule Tiger.Text.Lemmatizer.SpecTest.Macro do
  alias Tiger.Text.Tokenizer, as: Tokenizer
  alias Tiger.Text.Token.Spec, as: Spec
  alias Tiger.Text.Lemmatizer.Spec, as: Lemmatizer

  import Tiger.Error, only: [gef: 2]
  import Opts, only: [opt: 1, flag: 1]

  # defmacro ensure(name, in: input, spec: spec, out: output) do
  defmacro ensure(name, opts) do
    input = opt :in
    spec = opt :spec
    output = opt :out

    flag :debug

    quote do
      test unquote(name) do
        gef tokens: Tokenizer.split(unquote(input)) do
          gef spec: Spec.init(unquote(spec)) do
            gef lemmas: Lemmatizer.apply(var!(spec), var!(tokens), debug: unquote(debug)) do
              assert Tokenizer.join(var!(lemmas)) == unquote(output)
            end
          end
        end
      end
    end
  end
end

defmodule Tiger.Text.Lemmatizer.SpecTest do
  use ExUnit.Case

  # alias Tiger.Text.Lemmatizer.Spec, as: Lemmatizer
  # alias Tiger.Text.Token.Spec, as: Spec
  # alias Tiger.Text.Tokenizer, as: Tokenizer

  # import Tiger.Error

  import Tiger.Text.Lemmatizer.SpecTest.Macro

  ensure "nonexistent token with debugging", in: "foo bar", spec: "fo.", out: "f## bar", debug: true
  ensure "nonexistent token without debugging", in: "foo bar", spec: "fo.", out: "f bar"

  ensure "one letter with debugging", in: "f bar", spec: "f", out: "## bar", debug: true
  ensure "one letter without debugging", in: "f bar", spec: "f", out: " bar", debug: false

  ensure "indices", in: "foo bar foo bar", spec: "fo.@2", out: "foo bar f## bar", debug: true
  ensure "reverse order", in: "foo bar foo bar", spec: "fo.@2 fo.@1", out: "f## bar f## bar", debug: true

  ensure "invalid indices", in: "bar bar foo foo", spec: "foo.@12 foo.@3 fo.@2 fo.@1", out: "bar bar f## f##", debug: true

  # test "single token" do
  #   # wrap Spec.init("fo.") do
  #   #   IO.inspect val
  #   # end

  #   # get tokens: Tokenizer.split("foo bar") do
  #   #   gen spec: Spec.init("fo.") do
  #   #     gen lemmas: Lemmatizer.apply(spec, tokens, debug: true) do
  #   #       assert Tokenizer.join(lemmas) == "f## bar"
  #   #     end
  #   #   end
  #   # end |> IO.inspect

  #   gef tokens: Tokenizer.split("foo bar") do
  #     IO.inspect tokens
  #     gef spec: Spec.init("fo.") do
  #       gef lemmas: Lemmatizer.apply(spec, tokens, debug: true) do
  #         assert Tokenizer.join(lemmas) == "f## bar"
  #       end
  #     end
  #   end
  # end
end
