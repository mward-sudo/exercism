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
  def mul(a, b) do
    {a_real, a_imaginary} = make_complex(a)
    {b_real, b_imaginary} = make_complex(b)

    {
      a_real * b_real - a_imaginary * b_imaginary,
      a_real * b_imaginary + a_imaginary * b_real
    }
  end

  @doc """
  Add two complex numbers, or a real and a complex number
  """
  @spec add(a :: complex | float, b :: complex | float) :: complex
  def add(a, b) do
    {a_real, a_imaginary} = make_complex(a)
    {b_real, b_imaginary} = make_complex(b)

    {
      a_real + b_real,
      a_imaginary + b_imaginary
    }
  end

  @doc """
  Subtract two complex numbers, or a real and a complex number
  """
  @spec sub(a :: complex | float, b :: complex | float) :: complex
  def sub(a, b) do
    {a_real, a_imaginary} = make_complex(a)
    {b_real, b_imaginary} = make_complex(b)

    {
      a_real - b_real,
      a_imaginary - b_imaginary
    }
  end

  @doc """
  Divide two complex numbers, or a real and a complex number
  """
  @spec div(a :: complex | float, b :: complex | float) :: complex
  def div(a, b) do
    {a_real, a_imaginary} = make_complex(a)
    {b_real, b_imaginary} = make_complex(b)

    {
      (a_real * b_real + a_imaginary * b_imaginary) /
        (b_real * b_real + b_imaginary * b_imaginary),
      (a_imaginary * b_real - a_real * b_imaginary) /
        (b_real * b_real + b_imaginary * b_imaginary)
    }
  end

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
  def exp({real, imaginary}) do
    {
      :math.exp(real) * :math.cos(imaginary),
      :math.exp(real) * :math.sin(imaginary)
    }
  end

  defp make_complex(a) when is_number(a), do: {a, 0}
  defp make_complex(a), do: a
end
