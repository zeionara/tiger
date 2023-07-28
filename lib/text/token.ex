defmodule Tiger.Text.Token do
  import Tiger.Util.String, only: [rjoin: 1]

  defstruct [:raw, :sep]

  def init(raw, sep) do
    %Tiger.Text.Token{
      raw: (if raw == nil, do: "", else: raw |> rjoin),
      sep: (if sep == nil, do: "", else: sep |> rjoin)
    }
  end
end
