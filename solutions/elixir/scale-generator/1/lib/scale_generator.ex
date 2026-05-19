defmodule ScaleGenerator do
  @sharp_notes ~w(A A# B C C# D D# E F F# G G#)
  @flat_notes ~w(A Bb B C Db D Eb E F Gb G Ab)
  @flat_tonics ~w(F Bb Eb Ab Db Gb d g c f bb eb)

  defp normalize_tonic(tonic), do: String.capitalize(tonic)

  defp rotate_scale(scale, tonic) do
    index = Enum.find_index(scale, &(&1 == tonic))
    Enum.slice(scale, index..-1) ++ Enum.slice(scale, 0..index)
  end

  defp step_index("m"), do: 1
  defp step_index("M"), do: 2
  defp step_index("A"), do: 3

  @doc """
  Find the note for a given interval (`step`) in a `scale` after the `tonic`.

  "m": one semitone
  "M": two semitones (full tone)
  "A": augmented second (three semitones)

  Given the `tonic` "D" in the `scale` (C C# D D# E F F# G G# A A# B C), you
  should return the following notes for the given `step`:

  "m": D#
  "M": E
  "A": F
  """
  @spec step(scale :: list(String.t()), tonic :: String.t(), step :: String.t()) :: String.t()
  def step(scale, tonic, step) do
    index = Enum.find_index(scale, &(&1 == tonic))
    Enum.at(scale, rem(index + step_index(step), length(scale)))
  end

  @doc """
  The chromatic scale is a musical scale with thirteen pitches, each a semitone
  (half-tone) above or below another.

  Notes with a sharp (#) are a semitone higher than the note below them, where
  the next letter note is a full tone except in the case of B and E, which have
  no sharps.

  Generate these notes, starting with the given `tonic` and wrapping back
  around to the note before it, ending with the tonic an octave higher than the
  original. If the `tonic` is lowercase, capitalize it.

  "C" should generate: ~w(C C# D D# E F F# G G# A A# B C)
  """
  @spec chromatic_scale(tonic :: String.t()) :: list(String.t())
  def chromatic_scale(tonic \\ "C") do
    tonic = normalize_tonic(tonic)
    rotate_scale(@sharp_notes, tonic)
  end

  @doc """
  Sharp notes can also be considered the flat (b) note of the tone above them,
  so the notes can also be represented as:

  A Bb B C Db D Eb E F Gb G Ab

  Generate these notes, starting with the given `tonic` and wrapping back
  around to the note before it, ending with the tonic an octave higher than the
  original. If the `tonic` is lowercase, capitalize it.

  "C" should generate: ~w(C Db D Eb E F Gb G Ab A Bb B C)
  """
  @spec flat_chromatic_scale(tonic :: String.t()) :: list(String.t())
  def flat_chromatic_scale(tonic \\ "C") do
    tonic = normalize_tonic(tonic)
    rotate_scale(@flat_notes, tonic)
  end

  @doc """
  Certain scales will require the use of the flat version, depending on the
  `tonic` (key) that begins them, which is C in the above examples.

  For any of the following tonics, use the flat chromatic scale:

  F Bb Eb Ab Db Gb d g c f bb eb

  For all others, use the regular chromatic scale.
  """
  @spec find_chromatic_scale(tonic :: String.t()) :: list(String.t())
  def find_chromatic_scale(tonic) do
    normalized_tonic = normalize_tonic(tonic)

    if Enum.member?(@flat_tonics, tonic) do
      flat_chromatic_scale(normalized_tonic)
    else
      chromatic_scale(normalized_tonic)
    end
  end

  @doc """
  The `pattern` string will let you know how many steps to make for the next
  note in the scale.

  For example, a C Major scale will receive the pattern "MMmMMMm", which
  indicates you will start with C, make a full step over C# to D, another over
  D# to E, then a semitone, stepping from E to F (again, E has no sharp). You
  can follow the rest of the pattern to get:

  C D E F G A B C
  """
  @spec scale(tonic :: String.t(), pattern :: String.t()) :: list(String.t())
  def scale(tonic, pattern) do
    scale = find_chromatic_scale(tonic)
    tonic = normalize_tonic(tonic)

    pattern
    |> String.graphemes()
    |> Enum.reduce([tonic], fn step, [prev | _] = acc ->
      [step(scale, prev, step) | acc]
    end)
    |> Enum.reverse()
  end
end
