defmodule Forth do
  @moduledoc """
  A simple Forth interpreter that supports basic arithmetic operations,
  stack manipulation, and custom word definitions.
  """

  @opaque evaluator :: %{stack: [integer()], words: %{String.t() => [String.t()]}}

  @doc """
  Create a new evaluator.

  Returns a new Forth evaluator with an empty stack and no custom word definitions.
  """
  @spec new() :: evaluator
  def new do
    %{stack: [], words: %{}}
  end

  @doc """
  Evaluate an input string, updating the evaluator state.

  Takes a Forth evaluator and a string of space-separated tokens, processes each token,
  and returns the updated evaluator state. Supports arithmetic operations (+, -, *, /),
  stack manipulation (DUP, DROP, SWAP, OVER), and custom word definitions.

  ## Examples

      iex> Forth.new() |> Forth.eval("1 2 +") |> Forth.format_stack()
      "3"

  """
  @spec eval(evaluator, String.t()) :: evaluator
  def eval(evaluator, input) do
    tokens = tokenize(input)
    process_tokens(evaluator, tokens)
  end

  @doc """
  Return the current stack as a string with the element on top of the stack
  being the rightmost element in the string.

  ## Examples

      iex> Forth.new() |> Forth.eval("1 2 3") |> Forth.format_stack()
      "1 2 3"

  """
  @spec format_stack(evaluator) :: String.t()
  def format_stack(evaluator) do
    evaluator.stack
    |> Enum.reverse()
    |> Enum.map_join(" ", &Integer.to_string/1)
  end

  # Tokenize the input string by splitting on whitespace
  @spec tokenize(String.t()) :: [String.t()]
  defp tokenize(input) do
    # Split on any Unicode whitespace or control characters
    input
    |> String.split(~r/[\s\x00-\x1F]+/u, trim: true)
  end

  # Process a list of tokens
  @spec process_tokens(evaluator, [String.t()]) :: evaluator
  defp process_tokens(evaluator, []), do: evaluator

  defp process_tokens(evaluator, [":" | rest]) do
    process_definition(evaluator, rest)
  end

  defp process_tokens(evaluator, [token | rest]) do
    evaluator
    |> process_token(token)
    |> process_tokens(rest)
  end

  # Process a single token
  @spec process_token(evaluator, String.t()) :: evaluator
  defp process_token(evaluator, token) do
    if number?(token) do
      push_number(evaluator, token)
    else
      execute_word(evaluator, String.downcase(token))
    end
  end

  # Check if a token is a number (including negative numbers)
  @spec number?(String.t()) :: boolean()
  defp number?(token) do
    case Integer.parse(token) do
      {_num, ""} -> true
      _ -> false
    end
  end

  # Push a number onto the stack
  @spec push_number(evaluator, String.t()) :: evaluator
  defp push_number(evaluator, token) do
    {num, _} = Integer.parse(token)
    %{evaluator | stack: [num | evaluator.stack]}
  end

  # Execute a word (built-in or user-defined)
  @spec execute_word(evaluator, String.t()) :: evaluator
  defp execute_word(evaluator, word) do
    if Map.has_key?(evaluator.words, word) do
      execute_custom_word(evaluator, word)
    else
      execute_builtin_word(evaluator, word)
    end
  end

  # Execute a custom word by processing its definition
  @spec execute_custom_word(evaluator, String.t()) :: evaluator
  defp execute_custom_word(evaluator, word) do
    definition = Map.get(evaluator.words, word)
    process_tokens(evaluator, definition)
  end

  # Execute a built-in word
  @spec execute_builtin_word(evaluator, String.t()) :: evaluator
  defp execute_builtin_word(evaluator, "+"), do: arithmetic_op(evaluator, &+/2)
  defp execute_builtin_word(evaluator, "-"), do: arithmetic_op(evaluator, &-/2)
  defp execute_builtin_word(evaluator, "*"), do: arithmetic_op(evaluator, &*/2)
  defp execute_builtin_word(evaluator, "/"), do: division_op(evaluator)
  defp execute_builtin_word(evaluator, "dup"), do: dup(evaluator)
  defp execute_builtin_word(evaluator, "drop"), do: drop(evaluator)
  defp execute_builtin_word(evaluator, "swap"), do: swap(evaluator)
  defp execute_builtin_word(evaluator, "over"), do: over(evaluator)
  defp execute_builtin_word(_evaluator, word), do: raise(Forth.UnknownWord, word: word)

  # Perform an arithmetic operation
  @spec arithmetic_op(evaluator, (integer(), integer() -> integer())) :: evaluator
  defp arithmetic_op(%{stack: [b, a | rest]} = evaluator, op) do
    result = op.(a, b)
    %{evaluator | stack: [result | rest]}
  end

  defp arithmetic_op(%{stack: stack}, _op) when length(stack) < 2 do
    raise Forth.StackUnderflow
  end

  # Division operation with zero check
  @spec division_op(evaluator) :: evaluator
  defp division_op(%{stack: [0 | _]}) do
    raise Forth.DivisionByZero
  end

  defp division_op(%{stack: [b, a | rest]} = evaluator) do
    result = div(a, b)
    %{evaluator | stack: [result | rest]}
  end

  defp division_op(%{stack: stack}) when length(stack) < 2 do
    raise Forth.StackUnderflow
  end

  # DUP: Duplicate the top element
  @spec dup(evaluator) :: evaluator
  defp dup(%{stack: [top | _] = stack} = evaluator) do
    %{evaluator | stack: [top | stack]}
  end

  defp dup(%{stack: []}) do
    raise Forth.StackUnderflow
  end

  # DROP: Remove the top element
  @spec drop(evaluator) :: evaluator
  defp drop(%{stack: [_ | rest]} = evaluator) do
    %{evaluator | stack: rest}
  end

  defp drop(%{stack: []}) do
    raise Forth.StackUnderflow
  end

  # SWAP: Swap the top two elements
  @spec swap(evaluator) :: evaluator
  defp swap(%{stack: [a, b | rest]} = evaluator) do
    %{evaluator | stack: [b, a | rest]}
  end

  defp swap(%{stack: stack}) when length(stack) < 2 do
    raise Forth.StackUnderflow
  end

  # OVER: Copy the second element to the top
  @spec over(evaluator) :: evaluator
  defp over(%{stack: [_a, b | _rest] = stack} = evaluator) do
    %{evaluator | stack: [b | stack]}
  end

  defp over(%{stack: stack}) when length(stack) < 2 do
    raise Forth.StackUnderflow
  end

  # Process a word definition
  @spec process_definition(evaluator, [String.t()]) :: evaluator
  defp process_definition(evaluator, tokens) do
    case find_definition_end(tokens) do
      {:ok, word_name, definition, rest} ->
        word_name_lower = String.downcase(word_name)

        # Check if the word name is a number
        if number?(word_name) do
          raise Forth.InvalidWord, word: word_name
        end

        # Expand the definition to capture current word meanings
        expanded_definition = expand_definition(evaluator, definition)

        # Store the expanded definition
        updated_evaluator = %{
          evaluator
          | words: Map.put(evaluator.words, word_name_lower, expanded_definition)
        }

        # Continue processing remaining tokens
        process_tokens(updated_evaluator, rest)

      :error ->
        raise ArgumentError, message: "definition not terminated with ;"
    end
  end

  # Expand a definition by replacing custom words with their definitions
  @spec expand_definition(evaluator, [String.t()]) :: [String.t()]
  defp expand_definition(evaluator, tokens) do
    Enum.flat_map(tokens, fn token ->
      token_lower = String.downcase(token)

      cond do
        # Numbers and built-in words stay as-is
        number?(token) -> [token]
        builtin_word?(token_lower) -> [token]
        # Custom words get expanded to their current definition
        Map.has_key?(evaluator.words, token_lower) ->
          Map.get(evaluator.words, token_lower)

        # Unknown words stay as-is (will error at execution time)
        true ->
          [token]
      end
    end)
  end

  # Check if a word is a built-in word
  @spec builtin_word?(String.t()) :: boolean()
  defp builtin_word?(word) do
    word in ["+", "-", "*", "/", "dup", "drop", "swap", "over"]
  end

  # Find the end of a definition (the semicolon)
  @spec find_definition_end([String.t()]) ::
          {:ok, String.t(), [String.t()], [String.t()]} | :error
  defp find_definition_end([word_name | rest]) do
    case find_semicolon(rest, []) do
      {:ok, definition, remaining} ->
        {:ok, word_name, definition, remaining}

      :error ->
        :error
    end
  end

  defp find_definition_end([]), do: :error

  # Find the semicolon that ends a definition
  @spec find_semicolon([String.t()], [String.t()]) ::
          {:ok, [String.t()], [String.t()]} | :error
  defp find_semicolon([], _acc), do: :error

  defp find_semicolon([";" | rest], acc) do
    {:ok, Enum.reverse(acc), rest}
  end

  defp find_semicolon([token | rest], acc) do
    find_semicolon(rest, [token | acc])
  end

  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end
