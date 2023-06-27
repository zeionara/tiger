{opts, _, _} = OptionParser.parse(
  System.argv,
  strict: [
    board: :string,
    list: :string,
    name: :string,
    verbose: :boolean
  ], aliases: [
    b: :board,
    l: :list,
    n: :name,
    v: :verbose
  ]
)

verbose = Keyword.get(opts, :verbose, false)

case opts[:board] do
  nil -> IO.puts('Missing board id argument')
  board -> 
    case opts[:list] do
      nil -> IO.puts('Missing list name argument')
      list ->
        case Keyword.get(opts, :name, "test card") do
          nil -> IO.puts('Missing card name argument')
          name -> Tiger.create_card(board, list, name, verbose: verbose) |> IO.inspect
        end
    end
end
