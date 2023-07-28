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
import Error, only: [wrap: 2] # , escalate: 1]

alias Tiger.Commit.Title, as: Title
alias Tiger.Commit.Description, as: Description
alias Tiger.Command.Struct, as: Command
alias Tiger.Text.Token.Spec, as: Spec

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

                description: oop(:description, handle: fn value -> value |> String.trim |> String.capitalize end),
                # description: Formatter.parse_body(opts, :description),
                members: Formatter.parse_list(opts, :members),
                labels: Formatter.parse_list(opts, :tags),
                due: parse_date.(:complete, now),
                done: Keyword.get(opts, :done, false)
            ) |> IO.inspect
          end
      end
  end
end

merge_label_lists = fn (labels) -> 
  case labels do
    nil -> Formatter.parse_list(opts, :tags)
    labels -> case Formatter.parse_list(opts, :tags) do
      nil -> labels
      [ "" ] -> labels
      parsed_labels -> Llist.merge(labels, parsed_labels)
    end
  end
end

parse_some = fn (name, labels, description) ->
  opt :board, handle: fn board ->
    opt :list, handle: fn list ->
      Tiger.create_card(board, list, name,
        verbose: verbose,
        skip: skip,
        zoom: bop(:zoom),

        # description: oop(:description, handle: fn value -> value |> String.trim |> String.capitalize end),
        # description: Formatter.parse_body(opts, :description),
        description: description,
        members: Formatter.parse_list(opts, :members),
        labels: merge_label_lists.(labels),
        due: parse_date.(:complete, now),
        done: bop(:done)
      ) # |> IO.inspect
    end
  end
end


close = fn (signature, labels) ->
  opt :board, handle: fn board ->
    Tiger.close_card(board, signature,
      verbose: verbose,
      labels: merge_label_lists.(labels),
      zoom: bop(:zoom),
      due: parse_date.(:complete, now)
    )
  end
end

case opt :commit_title do
  nil -> parse_all.()
  # title -> wrap Commit.parse(title, opt :commit_description), handle: fn task ->
  title -> wrap Tiger.Commit.Parser.parse(title, oop(:commit_description, handle: &Tiger.Commit.Description.drop_title/1)), handle: fn %Tiger.Commit.Message{
    title: title = %Title{
      type: type,
      scope: scope,
      content: %Tiger.Text.Struct{
        tokens: tokens
      }
    },
    description: %Description{
      content: content,
      commands: commands
    }
  } ->
    for command <- commands do
      case command do
        %Command{name: :create, args: []} ->
          IO.puts "empty create"
          # parse_some.(
          #   Keyword.get(task, :name, "test task"),
          #   Keyword.get(task, :labels),
          #   Keyword.get(task, :description)
          # )
        %Command{name: :create, args: [spec]} ->
          IO.puts "lemmatized create"
          # IO.inspect Title.labels(title)
          # IO.inspect tokens
          # IO.inspect Keyword.get(task, :tokens)
          IO.inspect spec
          IO.inspect spec |> Spec.init
          # wrap lemmatization_spec |> Lemmatizer.parse_spec, handle: fn spec ->
          #   wrap Lemmatizer.lemmatize(spec, Keyword.get(task, :tokens) |> elem(1)), handle: fn tokens ->
          #     parse_some.(
          #       tokens |> Tokenizer.join |> String.capitalize,
          #       Keyword.get(task, :labels),
          #       Keyword.get(task, :description)
          #     )
          #   end
          # end
          # parse_some.(
          #   Keyword.get(task, :name, "test task"),
          #   Keyword.get(task, :labels),
          #   Keyword.get(task, :description),
          #   lemmatization_spec
          # )
        %Command{name: :close, args: [symbol]} ->
          IO.puts "close"
          # case close.(symbol, task |> Keyword.get(:labels)) do
          #   {:ok, _} -> IO.puts "Closed task #{symbol}"
          #   {:error, message} ->
          #     IO.puts "Cannot close task #{symbol}. See details below"
          #     IO.inspect message
          # end
          # IO.puts "Handler for !close command is not implemented yet. Cannot close task #{symbol} for you, please do it manually"
        %Command{name: :make, args: [name: name, description: description]} ->
          IO.puts "Handler for make command is not implemented yet. Cannot make task with name '#{name}' and description '#{description}' for you, please do it manually"
        %Command{name: :make, args: [symbol]} ->
          IO.puts "Handler for make command is not implemented yet. Cannot make task #{symbol} for you, please do it manually"
      end
    end
  end
end

# Keyword.get(opts, :commit_title) |> Commit.parse(Keyword.get(opts, :commit_description)) |> IO.inspect
# parse_some.(:foo, :bar)
