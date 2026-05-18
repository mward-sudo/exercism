defmodule Wordy do
  @doc """
  Calculate the math problem in the sentence.
  """
  @spec answer(String.t()) :: integer
  def answer(question) do
    question
    |> String.trim_trailing("?")
    |> String.replace_prefix("What is ", "")
    |> String.split()
    |> parse_and_calculate()
  end

  defp parse_and_calculate(tokens) do
    case tokens do
      [number] -> parse_number(number)
      _ -> do_calculate(tokens, nil)
    end
  end

  defp do_calculate([], acc), do: acc
  defp do_calculate([number | rest], nil), do: do_calculate(rest, parse_number(number))

  defp do_calculate(["plus", number | rest], acc),
    do: do_calculate(rest, acc + parse_number(number))

  defp do_calculate(["minus", number | rest], acc),
    do: do_calculate(rest, acc - parse_number(number))

  defp do_calculate(["multiplied", "by", number | rest], acc),
    do: do_calculate(rest, acc * parse_number(number))

  defp do_calculate(["divided", "by", number | rest], acc),
    do: do_calculate(rest, div(acc, parse_number(number)))

  defp do_calculate(_, _), do: raise(ArgumentError)

  defp parse_number(str), do: String.to_integer(str)
end
