{opts, _, _} = OptionParser.parse(
  System.argv,
  strict: [
    board: :string,
    list: :string,
    name: :string,
  ], aliases: [
    b: :board,
    l: :list,
    n: :name
  ]
)

case opts[:board] do
  nil -> IO.puts('Missing board id argument')
  board -> 
    case opts[:list] do
      nil -> IO.puts('Missing list name argument')
      list ->
        case Keyword.get(opts, :name, "test card") do
          nil -> IO.puts('Missing card name argument')
          name -> Tiger.create_card(board: board, list: list, name: name) |> IO.inspect
        end
    end
end
