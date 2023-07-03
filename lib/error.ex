defmodule Error do
  defmacro wrap(call, handle: handle) do
    quote do
      case unquote(call) do
        {:ok, result} -> {:ok, unquote(handle).(result)}
        {:error, message} -> {:error, message}
        _ -> {:error, "Unrecognized result"}
      end
    end
  end
end
