defmodule Tiger.Commit.Description do
  import Tiger.Util.Collection, only: [second: 1]

  defstruct [:commands, :content]

  def drop_title(content) do
    parts = String.split(content, "\n", parts: 2)

    if length(parts) < 2 do # commit message consists of one line which is longer than 100 symbols
      nil
    else
      parts |> second # |> String.trim
    end
  end
end
