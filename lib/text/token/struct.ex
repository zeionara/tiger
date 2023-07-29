defmodule Tiger.Text.Token do
  import Tiger.Util.String, only: [rjoin: 1]

  defstruct [:raw, :sep]

  def init(raw, sep) do
    %Tiger.Text.Token{
      raw: (if raw == nil || length(raw) < 1, do: nil, else: raw |> rjoin),
      sep: (if sep == nil || length(sep) < 1, do: nil, else: sep |> rjoin)
    }
  end
end
