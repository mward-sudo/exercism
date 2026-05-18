# Credit goes to angelikatyborska for the solution, because I didn't know how to do it.

defmodule TopSecret do
  def to_ast(string) do
    {:ok, res} = Code.string_to_quoted(string)
    res
  end

  def decode_secret_message_part({op, _, args} = ast, acc) when op in [:def, :defp] do
    {function_name, function_args} = get_function_name_and_args(args)

    arity = length(function_args)

    message =
      function_name
      |> to_string()
      |> String.slice(0, arity)

    {ast, [message | acc]}
  end

  def decode_secret_message_part(ast, acc), do: {ast, acc}

  defp get_function_name_and_args([{:when, _, args} | _]), do: get_function_name_and_args(args)
  defp get_function_name_and_args([{name, _, args} | _]) when is_list(args), do: {name, args}
  defp get_function_name_and_args([{name, _, args} | _]) when is_atom(args), do: {name, []}

  def decode_secret_message(string) do
    ast = to_ast(string)
    {_, acc} = Macro.prewalk(ast, [], &decode_secret_message_part/2)

    acc
    |> Enum.reverse()
    |> Enum.join("")
  end
end
