{opts, _, _} = OptionParser.parse(
  System.argv,
  strict: [
    board: :string,
    list: :string,
    name: :string,
    description: :string,
    verbose: :boolean,
    members: :string
  ], aliases: [
    b: :board,
    l: :list,
    n: :name,
    v: :verbose,
    m: :members,
    d: :description
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
          name -> Tiger.create_card(board, list, name, verbose: verbose, description: Keyword.get(opts, :description),
              members: case Keyword.get(opts, :members) do
                nil -> nil
                members -> String.split(members, ",")
              end
          ) |> IO.inspect
        end
    end
end
