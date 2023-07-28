defmodule Tiger.Util.List do
  def first([ head | _ ]) do
    head
  end

  def second([ _ | [ next | _ ]]) do
    next
  end

  def third([ _ | [ _ | [ next | _ ]]]) do
    next
  end
end
