defmodule Formatter do
  @whitespace_pattern ~r/\s+/

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

  def to_kebab_case(string) do
    if String.match?(string, @whitespace_pattern) do
      {:ok, Regex.replace(@whitespace_pattern, string |> String.downcase, "-")}
    else
      {:ok, string |> String.downcase }
      # {:error, "Cannot infer naming convention of string '#{string}'"}
    end
  end

  def parse_date(opts, key) do
    {_, result} = case Keyword.get(opts, key) do
      nil -> {:ok, nil}
      value -> DateTimeParser.parse_date(value)
    end

    result
  end

  def encode_date(date) do
    case date do
      nil -> nil
      _ -> Date.to_iso8601(date)
    end
  end

  def parse_body(opts, key) do
    case Keyword.get(opts, key) do
      nil -> nil
      value -> value |> String.split("\n", parts: 2) |> Enum.at(1) |> String.trim
    end
  end
end
