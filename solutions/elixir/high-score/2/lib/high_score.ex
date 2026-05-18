defmodule HighScore do
  @initial_score 0

  def new(), do: %{}

  def add_player(scores, name), do: scores |> Map.put(name, @initial_score)

  def add_player(scores, name, score),
    do: scores |> Map.put(name, score)

  def remove_player(scores, name), do: scores |> Map.delete(name)

  def reset_score(scores, name), do: scores |> Map.put(name, @initial_score)

  def update_score(scores, name, score) do
    scores
    |> Map.update(name, score, fn current_score -> current_score + score end)
  end

  def get_players(scores), do: scores |> Map.keys()
end
