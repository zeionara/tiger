defmodule Formatter do
  def parse_list(opts, key) do
    case Keyword.get(opts, key) do
      nil -> nil
      value -> String.split(value, ",")
    end
  end

  def join_list(items) do
    case items do
      nil -> nil
      _ -> Enum.join(items, ",")
    end 
  end
end
