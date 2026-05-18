defmodule PigLatin do
  @vowel_sounds ~r/^(?<vowels>[aeiou]+|x[^aeiou]+|y[^aeiou]+)/
  @consonant_cluster ~r/^(?<consonants>^y|qu|[^aeiouy]+)(?<rest>.*)$/
  @consonant_cluster_with_qu ~r/^(?<consonants>[^aeiou]+)(?<qu>qu)(?<rest>.*)$/

  @doc """
  Given a `phrase`, translate it a word at a time to Pig Latin.
  """
  @spec translate(phrase :: String.t()) :: String.t()
  def translate(phrase) do
    phrase
    |> String.split(" ")
    |> Enum.map(&translate_word/1)
    |> Enum.join(" ")
  end

  defp translate_word(word) do
    case identify_word_type(word) do
      :vowel_sound -> word <> "ay"
      :qu_sound -> translate_qu_sound(word)
      :consonant_sound -> translate_consonant_sound(word)
    end
  end

  defp identify_word_type(word) do
    cond do
      vowel_sound?(word) -> :vowel_sound
      consonant_cluster_with_qu?(word) -> :qu_sound
      true -> :consonant_sound
    end
  end

  defp translate_qu_sound(word) do
    %{"consonants" => consonants, "qu" => qu, "rest" => rest} =
      Regex.named_captures(@consonant_cluster_with_qu, word)

    rest <> consonants <> qu <> "ay"
  end

  defp translate_consonant_sound(word) do
    %{"consonants" => consonants, "rest" => rest} = Regex.named_captures(@consonant_cluster, word)
    rest <> consonants <> "ay"
  end

  # Starts with any value from @vowel_sounds
  defp vowel_sound?(word), do: String.match?(word, @vowel_sounds)

  # Starts with any number of letters not in @vowel_sounds, followed by "qu"
  defp consonant_cluster_with_qu?(word), do: String.match?(word, @consonant_cluster_with_qu)
end
