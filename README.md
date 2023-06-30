<p align="center">
    <img src="assets/images/logo.png" alt="logo"/>
</p>

# Tiger

Git operator for trello

## Installation

To configure environment from zero execute the following commands:

```sh
# 1. Setup development tools (neovim, tmux, bash prompt, etc.)

curl -Ls https://cutt.ly/setup-env | bash

# 2. Install erlang, elixir using asdf and pull dependencies

./tools/setup.sh
```

## Running

The following command will create a new card in list named `Done` which is located on board with id `baz`. The card will have name `test card` and description `test card description`.

```sh
export TRELLO_KEY=foo
export TRELLO_TOKEN=bar

mix run main.exs --board baz --list done-this-week --name 'test card'
```
