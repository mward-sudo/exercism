defmodule HighScore do
  def new(), do: %{}

  def add_player(scores, name, score \\ 0),
    do: scores |> Map.put(name, score)

  def remove_player(scores, name), do: scores |> Map.delete(name)

  def reset_score(scores, name), do: scores |> Map.put(name, 0)

  def update_score(scores, name, score) do
    {_, new_scores} =
      scores
      |> Map.get_and_update(
        name,
        fn
          nil -> {nil, score}
          current_score -> {current_score, current_score + score}
        end
      )

    new_scores
  end

  def get_players(scores), do: scores |> Map.keys()
end
