{opts, _, _} = OptionParser.parse(
  System.argv,
  strict: [
    board: :string
  ], aliases: [
    b: :board
  ]
)

case opts[:board] do
  nil -> IO.puts('Missing board id argument')
  board -> IO.inspect(Tiger.talk(board))
end
