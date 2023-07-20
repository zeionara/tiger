defmodule Error do
  defmacro wrap(call, handle: handle) do
    quote do
      case unquote(call) do
        {:ok, result} -> {:ok, unquote(handle).(result)}
        {:error, message} -> {:error, message}
        # result -> {:error, "Unrecognized result", result}
      end
    end
  end

  defmacro wrapn(call, handle: handle) do
    quote do
      case unquote(call) do
        {:ok, result} -> unquote(handle).(result)
        {:error, message} -> {:error, message}
        # result -> {:error, "Unrecognized result", result}
      end
    end
  end

  defmacro escalate(call) do
    quote do
      case unquote(call) do
        {:ok, result} -> IO.inspect result
        {:error, message} -> raise message
      end
    end
  end

  def unwrap!({:ok, content}) do
    content
  end
end
