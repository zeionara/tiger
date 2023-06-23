# Tiger

Git operator for trello

## Running

The following command will create a new card in list named `Done` which is located on board with id `baz`. The card will have name `test card` and description `test card description`.

```sh
export TRELLO_KEY=foo
export TRELLO_TOKEN=bar

mix run main.exs --board baz --list Done --name 'test card'
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tiger` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tiger, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/tiger>.
