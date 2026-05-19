defmodule RPNCalculator.Exception do
  defmodule DivisionByZeroError do
    defexception message: "division by zero occurred"
  end

  defmodule StackUnderflowError do
    defexception message: "stack underflow occurred"

    @impl true
    def exception(value) do
      case value do
        [] -> %StackUnderflowError{}
        _ -> %StackUnderflowError{message: "stack underflow occurred, context: " <> value}
      end
    end
  end

  def divide(stack) when length(stack) <= 1,
    do: raise(RPNCalculator.Exception.StackUnderflowError, "when dividing")

  def divide(stack) when hd(stack) == 0, do: raise(RPNCalculator.Exception.DivisionByZeroError)
  def divide(stack), do: div(hd(tl(stack)), hd(stack))
end
