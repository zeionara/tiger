defmodule Tiger.Text.Lemmatizer.Spec do
  import Tiger.Opt, only: [deff: 1]

  alias Tiger.Text.Token, as: Token
  alias Tiger.Text.Spec, as: Spec

  alias Tiger.Text.Lemmatizer.Wrapper, as: Wrapper

  import Tiger.Error, only: [set: 2]

  def lemmatize(engine, token = %Token{raw: raw}, opts) do
    set lemma: Wrapper.parse(engine, raw, opts) do
      %Token{token | raw: lemma}
    end
  end

  def apply(spec, text, opts \\ []) do
    deff :debug

    engine = if debug do
      nil
    else
      Wrapper.new
    end

    spec |> Spec.apply(
      text, fn token ->
        lemmatize(engine, token, opts)
      end
    )
  end
end
