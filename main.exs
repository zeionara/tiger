{opts, _, _} = OptionParser.parse(
  System.argv,
  strict: [
    board: :string,
    list: :string,
    name: :string,
    description: :string,
    verbose: :boolean,
    members: :string,
    tags: :string, # tags = labels
    skip: :boolean # skip errors when possible (for example, when incorrect member or label are provided)
  ], aliases: [
    b: :board,
    l: :list,
    n: :name,
    v: :verbose,
    m: :members,
    d: :description,
    t: :tags, # tags = labels
    s: :skip
  ]
)

# IO.inspect(opts)

verbose = Keyword.get(opts, :verbose, false)
skip = Keyword.get(opts, :skip, false)

case opts[:board] do
  nil -> IO.puts('Missing board id argument')
  board -> 
    case opts[:list] do
      nil -> IO.puts('Missing list name argument')
      list ->
        case Keyword.get(opts, :name, "test card") do
          nil -> IO.puts('Missing card name argument')
          name -> Tiger.create_card(board, list, name,
              verbose: verbose,
              skip: skip,

              description: Keyword.get(opts, :description),
              members: Formatter.parse_list(opts, :members),
              labels: Formatter.parse_list(opts, :tags)
          ) |> IO.inspect
        end
    end
end
