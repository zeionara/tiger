defmodule Opts do
  defp make_ast(name, default: default) do
    quote do
      unquote(Macro.var(name, nil)) = Keyword.get(var!(opts), unquote(name), unquote(default))
    end
  end

  defmacro flag(name) do
    make_ast(name, default: false)
    # quote do
    #   # var!(unquote(name)) = Keyword.get(var!(opts), unquote(name), false)
    #   unquote(Macro.var(name, nil)) = Keyword.get(var!(opts), unquote(name), false)
    # end
  end

  defmacro rflag(name) do
    make_ast(name, default: true)
    # quote do
    #   # var!(unquote(name)) = Keyword.get(var!(opts), unquote(name), false)
    #   unquote(Macro.var(name, nil)) = Keyword.get(var!(opts), unquote(name), false)
    # end
  end

  defmacro val(name, default: default) do
    quote do
      unquote(Macro.var(name, nil)) = Keyword.get(var!(opts), unquote(name), unquote(default))
    end
  end

  defmacro opt(name, handle: handle) do
    quote do
      case var!(opts) |> Keyword.get(unquote(name)) do
        nil -> "Missing required property #{unquote(name)}" |> IO.puts
        result -> unquote(handle).(result)
      end
    end
  end

  defmacro oop(name, handle: handle) do
    quote do
      case var!(opts) |> Keyword.get(unquote(name)) do
        nil -> nil
        value -> unquote(handle).(value)
      end
    end
  end

  defmacro opt(name, default: default) do
    quote do
      case Keyword.get(var!(opts), unquote(name)) do
        nil -> unquote(default)
        value -> value
      end
    end
  end

  defmacro opt(name) do
    quote do
      Keyword.get(var!(opts), unquote(name))
    end
  end

  defmacro bop(name) do
    quote do
      Keyword.get(var!(opts), unquote(name), false)
    end
  end
end
