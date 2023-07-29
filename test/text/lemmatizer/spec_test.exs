defmodule Tiger.Text.Lemmatizer.SpecTest.Macro do
  alias Tiger.Text.Tokenizer, as: Tokenizer
  # alias Tiger.Text.Spec, as: Spec
  alias Tiger.Text.Spec.Parser, as: Parser
  alias Tiger.Text.Lemmatizer.Spec, as: Lemmatizer

  import Tiger.Error, only: [get: 2]
  import Tiger.Opt, only: [deff: 1, defr: 1, defo: 1, defo: 2]

  defmacro ensure(name, opts) do
    deff :debug
    defr :idempotent

    defo :in, as: :input
    defo :spec
    defo :out, as: :output

    quote do
      test unquote(name) do
        get tokens: Tokenizer.split(unquote(input)) do
          get spec: Parser.parse(unquote(spec)) do
            get lemmas: Lemmatizer.apply(var!(spec), var!(tokens), debug: unquote(debug), idempotent: unquote(idempotent)) do
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

  import Tiger.Text.Lemmatizer.SpecTest.Macro

  ensure "nonexistent token with debugging", in: "foo bar", spec: "fo.", out: "f## bar", debug: true
  ensure "nonexistent token without debugging", in: "foo bar", spec: "fo.", out: "f bar"

  ensure "one letter with debugging", in: "f bar", spec: "f", out: "## bar", debug: true
  ensure "one letter without debugging", in: "f bar", spec: "f", out: " bar", debug: false

  ensure "indices", in: "foo bar foo bar", spec: "fo.@2", out: "foo bar f## bar", debug: true

  ensure "reverse order", in: "foo foo", spec: "fo.@2 fo.@1", out: "f## f##", debug: true
  ensure "reverse order with intermediate tokens", in: "foo bar foo bar", spec: "fo.@2 fo.@1", out: "f## bar f## bar", debug: true
  ensure "invalid indices", in: "bar bar foo foo", spec: "foo.@12 foo.@3 fo.@2 fo.@1", out: "bar bar f## f##", debug: true

  ensure "similar patterns", in: "foo foo", spec: "fo.@1 f..@2", out: "f## f##", debug: true

  ensure "multiple patterns of various types", in: "foo bar Baz qux quux garply foo Waldo Bar fred", spec: "fo.@2 .ar q*", out: "foo b## Baz q## qu## garply f## Waldo B## fred", debug: true

  ensure "repetitive lemmatization", in: "foo", spec: "fo. f.. f.o", out: "fo##", debug: true, idempotent: false
end
