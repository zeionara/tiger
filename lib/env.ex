defmodule Env do
  defmacro flag(name) do
    quote do
      case System.get_env(unquote(name)) do
        nil -> false
        _ -> true
      end
    end
  end
end
