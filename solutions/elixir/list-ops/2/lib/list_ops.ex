defmodule ListOps do
  # Please don't use any external modules (especially List or Enum) in your
  # implementation. The point of this exercise is to create these basic
  # functions yourself. You may use basic Kernel functions (like `Kernel.+/2`
  # for adding numbers), but please do not use Kernel functions for Lists like
  # `++`, `--`, `hd`, `tl`, `in`, and `length`.

  @spec count(list) :: non_neg_integer
  # Uses foldl to count the number of elements in the list by incrementing an accumulator for each element.
  def count(l), do: foldl(l, 0, fn _, acc -> acc + 1 end)

  @spec reverse(list) :: list
  # Uses foldl to reverse the list by prepending each element to an accumulator list.
  def reverse(l), do: foldl(l, [], fn x, acc -> [x | acc] end)

  @spec map(list, (any -> any)) :: list
  # Uses foldr to apply a function to each element of the list, constructing a new list with the results.
  def map(l, f), do: foldr(l, [], fn x, acc -> [f.(x) | acc] end)

  @spec filter(list, (any -> as_boolean(term))) :: list
  # Uses foldr to filter elements of the list based on a predicate function.
  def filter(l, f), do: foldr(l, [], fn x, acc -> if f.(x), do: [x | acc], else: acc end)

  @type acc :: any
  @spec foldl(list, acc, (any, acc -> acc)) :: acc
  # Implements a left fold by recursively processing the list from the head to the tail, applying the function to each element and the accumulated result.
  def foldl([], acc, _f), do: acc
  def foldl([h | t], acc, f), do: foldl(t, f.(h, acc), f)

  @spec foldr(list, acc, (any, acc -> acc)) :: acc
  # Implements a right fold by recursively processing the list from the head to the tail, applying the function to each element and the accumulated result.
  def foldr([], acc, _f), do: acc
  def foldr([h | t], acc, f), do: f.(h, foldr(t, acc, f))

  @spec append(list, list) :: list
  # Uses foldr to append two lists by prepending each element of the first list to the second list.
  def append(a, b), do: foldr(a, b, fn x, acc -> [x | acc] end)

  @spec concat([[any]]) :: [any]
  # Uses foldr to concatenate a list of lists into a single list.
  def concat(ll), do: foldr(ll, [], &append/2)
end
