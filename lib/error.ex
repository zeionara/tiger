defmodule Tiger.Error do
  # defmacro wrap(call, do: expression) do
  #   quote do
  #     case unquote(call) do
  #       {:ok, result} ->
  #         unquote(Macro.var(:val, nil)) = result

  #         {:ok, unquote(expression)}
  #       {:error, message} -> {:error, message}
  #     end
  #   end
  # end
  
  def build_ast(opts, do: expression, wrap_result: wrap_result) do
    {var, call} = case opts do
      [{var, call} | _] -> {var, call}
      call -> {:val, call}
    end

    quote do
      case unquote(call) do
        {:ok, result} ->
          unquote(Macro.var(var, nil)) = result

          unquote(if wrap_result, do: {:ok, expression}, else: expression)
        {:error, message} -> {:error, message}
      end
    end
  end

  defmacro get(opts, do: expression) do
    build_ast(opts, do: expression, wrap_result: true)
  end

  defmacro gen(opts, do: expression) do # gen = get nested
    build_ast(opts, do: expression, wrap_result: false)
  end

  defmacro gef(opts, do: expression) do # gef = get from
    {var, call} = case opts do
      [{var, call} | _] -> {var, call}
      call -> {:val, call}
    end

    quote do
      case unquote(call) do
        {:ok, result} ->
          unquote(Macro.var(var, nil)) = result

          case unquote(expression) do
            {:ok, result} = response -> response
            result -> {:ok, result}
          end
        {:error, message} -> {:error, message}
      end
    end
  end
end

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
