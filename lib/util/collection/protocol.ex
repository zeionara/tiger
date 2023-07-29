defprotocol Tiger.Util.Collection do
  # @spec first(list(t)) :: t
  def first(items)
  # @spec second(list(t)) :: t
  def second(items)
  # @spec third(list(t)) :: t
  def third(items)

  # @spec last(list(t)) :: t
  def last(items)

  def reverse(items)
  def join(items, sep)
  def join(items)
  def chain(lhs, rhs)
  def transform(items, opts)

  def drop_last(items)
end
