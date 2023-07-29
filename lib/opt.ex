defmodule Tiger.Opt do
  defp make_getting_ast(name, default \\ nil) do
    quote do
      Keyword.get(var!(opts), unquote(name), unquote(default))
    end
  end

  defp make_assignment_ast(name, default: default, as: var) do
    quote do
      # unquote(Macro.var(name, nil)) = Keyword.get(var!(opts), unquote(name), unquote(default))
      unquote(Macro.var(var, nil)) = unquote(make_getting_ast(name, default))
    end
  end

  defp make_assignment_ast(name, default: default) do
    make_assignment_ast(name, default: default, as: name)
  end

  defp make_handling_ast(name, positive: positive_expression, negative: negative_expression) do
    quote do
      # case var!(opts) |> Keyword.get(unquote(name)) do

      case unquote(make_getting_ast(name)) do
        nil -> unquote(negative_expression)
        value ->
          unquote(Macro.var(name, nil)) = unquote(make_getting_ast(name))
          unquote(positive_expression)
      end
    end
  end

  # define

  defmacro deff(name) do
    make_assignment_ast(name, default: false)
  end

  defmacro defr(name) do # reverse flag
    make_assignment_ast(name, default: true)
  end

  defmacro defo(name, default: default, as: alias) do
    make_assignment_ast(name, default: default, as: alias)
  end

  defmacro defo(name, default: default) do
    make_assignment_ast(name, default: default)
  end

  defmacro defo(name, as: alias) do
    make_assignment_ast(name, default: nil, as: alias)
  end

  defmacro defo(name) do
    make_assignment_ast(name, default: nil, as: name)
  end

  # get, handle, and return result

  defmacro opt!(name, do: expression) do
    make_handling_ast(
      name, positive: expression, negative: quote do
        raise "Missing required property #{unquote(name)}"
      end
    )
  end

  defmacro opt?(name, do: expression) do
    make_handling_ast(name, positive: expression, negative: nil)
  end

  # get

  defmacro opt(name, default: default) do
    quote do
      case unquote(make_getting_ast(name)) do
        nil -> unquote(default)
        value -> value
      end
    end
  end

  defmacro opt(name) do
    make_getting_ast(name)
  end

  defmacro flag(name) do
    make_getting_ast(name, false)
  end
end
