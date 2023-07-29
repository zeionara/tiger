defmodule Tiger.Text.Lemmatizer.Wrapper do
  import Opts, only: [flag: 1, val: 2]

  @suffix "##"
  @length @suffix |> String.graphemes |> length

  defp guess(word) do
    "#{word |> String.slice(0..-3)}"
  end

  def parse(engine, word, opts \\ [debug: false]) do
    flag :debug

    if debug do
      {:ok, "#{word |> String.slice(0..-(@length + 1))}#{@suffix}"}
    else
      case engine |> Lemma.parse(word) do
        result = {:ok, _} -> result
        {:ambigious, alternatives} -> {:ok, alternatives |> Tiger.Util.List.first}
        {:error, "not possible"} -> {:ok, guess(word)}
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
    val :path, default: "assets"
    val :filename, default: "lemmatizer-state.bin"
    val :language, default: :en

    flag :no_cache
    flag :refresh

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
