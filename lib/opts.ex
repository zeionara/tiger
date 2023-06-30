defmodule Opts do
  defmacro flag(name) do
    quote do
      # var!(unquote(name)) = Keyword.get(var!(opts), unquote(name), false)
      unquote(Macro.var(name, nil)) = Keyword.get(var!(opts), unquote(name), false)
    end
  end
end
