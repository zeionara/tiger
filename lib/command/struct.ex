defmodule Tiger.Command.Struct do
  defstruct [:name, :args]

  def init(name, args) do
    %Tiger.Command.Struct{name: name, args: args}
  end
end
