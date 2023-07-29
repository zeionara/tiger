defmodule Tiger.Text.Lemmatizer.Wrapper do
  import Tiger.Opt, only: [deff: 1, defr: 1, defo: 2]
  import Tiger.Util.Collection, only: [first: 1]

  @suffix "##"
  @length @suffix |> String.graphemes |> length

  defp guess(word) do
    "#{word |> String.slice(0..-3)}" # drop last two letters
  end

  def parse(engine, word, opts \\ [debug: false]) do
    deff :debug
    defr :idempotent

    if debug do
      {:ok, "#{word |> String.slice(0..-(@length + if idempotent, do: 1, else: 0))}#{@suffix}"}
    else
      if idempotent do
        case engine |> Lemma.parse(word) do
          result = {:ok, _} -> result
          {:ambigious, alternatives} -> {:ok, alternatives |> first}
          {:error, "not possible"} -> {:ok, guess(word)}
        end
      else
        {:error, :incorrect_idempotent_option_use}
      end
    end
  end

  defp make(language) do
    language |> Lemma.new
  end

  defp cache(engine, path) do
    File.write! path, engine |> :erlang.term_to_binary
    engine
  end

  def new(opts \\ []) do
    deff :no_cache
    deff :refresh

    defo :path, default: "assets"
    defo :filename, default: "lemmatizer-state.bin"
    defo :language, default: :en

    if no_cache || path == nil || filename == nil do
      language |> make
    else
      joined = Path.join(path, filename)

      if File.exists?(joined) && !refresh do
        # IO.puts "file exists"
        File.read!(joined) |> :erlang.binary_to_term
      else
        # IO.puts "file does not exist"
        language |> make |> cache(joined)
        # engine = make language
        # File.write! joined, engine |> :erlang.term_to_binary
        # engine
      end
    end
  end
end
