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
    skip: :boolean, # skip errors when possible (for example, when incorrect member or label are provided)
    complete: :string, # complete until (due date)
    now: :boolean,
    done: :boolean,
    commit_title: :string,
    commit_description: :string,
    zoom: :boolean # put card at the top of the list
  ], aliases: [
    b: :board,
    l: :list,
    n: :name,
    v: :verbose,
    m: :members,
    d: :description,
    t: :tags, # tags = labels
    s: :skip,
    c: :complete,
    d: :done,
    ct: :commit_title,
    cd: :commit_description,
    z: :zoom
  ]
)

# IO.inspect opts

import Opts, only: [opt: 2, opt: 1, bop: 1, flag: 1, oop: 2]
import Error, only: [wrap: 2]

flag :verbose
flag :skip
flag :now

parse_date = fn (opt_name, now) ->
  case Formatter.parse_date(opts, opt_name) do
    nil ->
      if now do
        DateTime.utc_now()
      else
        nil
      end
    value -> value
  end
end

parse_all = fn () ->
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
                zoom: bop(:zoom),

                # description: oop(:description, handle: fn value -> value |> String.trim |> String.capitalize end),
                description: Formatter.parse_body(opts, :description),
                members: Formatter.parse_list(opts, :members),
                labels: Formatter.parse_list(opts, :tags),
                due: parse_date.(:complete, now),
                done: Keyword.get(opts, :done, false)
            ) |> IO.inspect
          end
      end
  end
end

parse_some = fn (name, labels) ->
  opt :board, handle: fn board ->
    opt :list, handle: fn list ->
      Tiger.create_card(board, list, name,
        verbose: verbose,
        skip: skip,
        zoom: bop(:zoom),

        # description: oop(:description, handle: fn value -> value |> String.trim |> String.capitalize end),
        description: Formatter.parse_body(opts, :description),
        members: Formatter.parse_list(opts, :members),
        labels: case labels do
          nil -> Formatter.parse_list(opts, :tags)
          labels -> case Formatter.parse_list(opts, :tags) do
            nil -> labels
            [ "" ] -> labels
            parsed_labels -> Llist.merge(labels, parsed_labels)
          end
        end,
        due: parse_date.(:complete, now),
        done: bop :done
      ) |> IO.inspect
    end
  end
end

case opt :commit_title do
  nil -> parse_all.()
  title -> wrap Commit.parse(title, opt :commit_description), handle: fn task ->
    parse_some.(
      Keyword.get(task, :name, "test task"),
      Keyword.get(task, :labels)
    )
  end
end

# Keyword.get(opts, :commit_title) |> Commit.parse(Keyword.get(opts, :commit_description)) |> IO.inspect
# parse_some.(:foo, :bar)
