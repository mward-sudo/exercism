defmodule Secrets do
  import Bitwise

  def secret_add(secret) do
    fn addend -> secret + addend end
  end

  def secret_subtract(secret) do
    fn minuend -> minuend - secret end
  end

  def secret_multiply(secret) do
    fn multiplier -> secret * multiplier end
  end

  def secret_divide(secret) do
    fn dividend -> Integer.floor_div(dividend, secret) end
  end

  def secret_and(secret) do
    fn bitwise_addend -> band(secret, bitwise_addend) end
  end

  def secret_xor(secret) do
    fn bitwise_xor -> bxor(secret, bitwise_xor) end
  end

  def secret_combine(secret_function1, secret_function2) do
    fn param ->
      param
      |> secret_function1.()
      |> secret_function2.()
    end
  end
end
