defmodule ComplexNumbers do
  @typedoc """
  In this module, complex numbers are represented as a tuple-pair containing the real and
  imaginary parts.
  For example, the real number `1` is `{1, 0}`, the imaginary number `i` is `{0, 1}` and
  the complex number `4+3i` is `{4, 3}'.
  """
  @type complex :: {float, float}

  @doc """
  Return the real part of a complex number
  """
  @spec real(a :: complex) :: float
  def real({real, _imaginary}), do: real

  @doc """
  Return the imaginary part of a complex number
  """
  @spec imaginary(a :: complex) :: float
  def imaginary({_, imaginary}), do: imaginary

  @doc """
  Multiply two complex numbers, or a real and a complex number
  """
  @spec mul(a :: complex | float, b :: complex | float) :: complex
  def mul({real_a, imaginary_a}, {real_b, imaginary_b}) do
    real = real_a * real_b - imaginary_a * imaginary_b
    imaginary = real_a * imaginary_b + imaginary_a * real_b

    {real, imaginary}
  end

  def mul({_, _} = a, b), do: mul(a, complex(b))
  def mul(a, {_, _} = b), do: mul(complex(a), b)
  def mul(a, b), do: mul(complex(a), complex(b))

  @doc """
  Add two complex numbers, or a real and a complex number
  """
  @spec add(a :: complex | float, b :: complex | float) :: complex
  def add({real_a, imaginary_a}, {real_b, imaginary_b}) do
    real = real_a + real_b
    imaginary = imaginary_a + imaginary_b

    {real, imaginary}
  end

  def add({_, _} = a, b), do: add(a, complex(b))
  def add(a, {_, _} = b), do: add({a, 0.0}, b)
  def add(a, b), do: add({a, 0.0}, complex(b))

  @doc """
  Subtract two complex numbers, or a real and a complex number
  """
  @spec sub(a :: complex | float, b :: complex | float) :: complex
  def sub({real_a, imaginary_a}, {real_b, imaginary_b}) do
    real = real_a - real_b
    imaginary = imaginary_a - imaginary_b

    {real, imaginary}
  end

  def sub({_, _} = a, b), do: sub(a, complex(b))
  def sub(a, {_, _} = b), do: sub(complex(a), b)
  def sub(a, b), do: sub(complex(a), complex(b))

  @doc """
  Divide two complex numbers, or a real and a complex number
  """
  @spec div(a :: complex | float, b :: complex | float) :: complex
  def div({real_a, imaginary_a}, {real_b, imaginary_b}) do
    real =
      (real_a * real_b + imaginary_a * imaginary_b) /
        (real_b * real_b + imaginary_b * imaginary_b)

    imaginary =
      (imaginary_a * real_b - real_a * imaginary_b) /
        (real_b * real_b + imaginary_b * imaginary_b)

    {real, imaginary}
  end

  def div({_, _} = a, b), do: __MODULE__.div(a, complex(b))
  def div(a, {_, _} = b), do: __MODULE__.div(complex(a), b)
  def div(a, b), do: __MODULE__.div(complex(a), complex(b))

  @doc """
  Absolute value of a complex number
  """
  @spec abs(a :: complex) :: float
  def abs({real, imaginary}), do: :math.sqrt(real * real + imaginary * imaginary)

  @doc """
  Conjugate of a complex number
  """
  @spec conjugate(a :: complex) :: complex
  def conjugate({real, imaginary}), do: {real, -imaginary}

  @doc """
  Exponential of a complex number
  """
  @spec exp(a :: complex) :: complex
  def exp({real_a, imaginary_a}) do
    real = :math.exp(real_a) * :math.cos(imaginary_a)
    imaginary = :math.exp(real_a) * :math.sin(imaginary_a)

    {real, imaginary}
  end

  defp complex(a) when is_number(a), do: {a, 0.0}
end
