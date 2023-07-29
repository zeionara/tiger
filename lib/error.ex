defmodule Tiger.Error do
  defp wrap(result, nested: nested) do
    if nested do
      quote do
        case unquote(result) do
          {:ok, result} = response -> response
          result -> {:ok, result}
        end
      end
    else
      quote do
        {:ok, unquote(result)}
      end
    end
  end

  defp make_ast(opts, do: expression, nested: nested) do
    {var, call} = case opts do
      [{var, call} | _] -> {var, call}
      call -> {:val, call}
    end

    quote do
      case unquote(call) do
        {:ok, result} ->
          unquote(Macro.var(var, nil)) = result
          unquote(wrap(expression, nested: nested))
        {:error, message} -> {:error, message}
      end
    end
  end

  defmacro set(opts, do: expression) do
    make_ast(opts, do: expression, nested: false)
  end

  defmacro get(opts, do: expression) do
    make_ast(opts, do: expression, nested: true)
  end
end

# defmodule Error do
#   defmacro wrap(call, handle: handle) do
#     quote do
#       case unquote(call) do
#         {:ok, result} -> {:ok, unquote(handle).(result)}
#         {:error, message} -> {:error, message}
#         # result -> {:error, "Unrecognized result", result}
#       end
#     end
#   end
# 
#   defmacro wrapn(call, handle: handle) do
#     quote do
#       case unquote(call) do
#         {:ok, result} -> unquote(handle).(result)
#         {:error, message} -> {:error, message}
#         # result -> {:error, "Unrecognized result", result}
#       end
#     end
#   end
# 
#   defmacro escalate(call) do
#     quote do
#       case unquote(call) do
#         {:ok, result} -> IO.inspect result
#         {:error, message} -> raise message
#       end
#     end
#   end
# 
#   def unwrap!({:ok, content}) do
#     content
#   end
# end
