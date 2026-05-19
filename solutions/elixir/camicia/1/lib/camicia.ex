defmodule Camicia do
  @doc """
    Simulate a card game between two players.
    Each player has a deck of cards represented as a list of strings.
    Returns a tuple with the result of the game:
    - `{:finished, cards, tricks}` if the game finishes with a winner
    - `{:loop, cards, tricks}` if the game enters a loop
    `cards` is the number of cards played.
    `tricks` is the number of central piles collected.

    ## Examples

      iex> Camicia.simulate(["2"], ["3"])
      {:finished, 2, 1}

      iex> Camicia.simulate(["J", "2", "3"], ["4", "J", "5"])
      {:loop, 8, 3}
  """

  @spec simulate(list(String.t()), list(String.t())) ::
          {:finished | :loop, non_neg_integer(), non_neg_integer()}
  def simulate(player_a, player_b) do
    play_round(player_a, player_b, 0, 0, MapSet.new(), :a)
  end

  # Start a new round - check for loop or game end
  @spec play_round(
          list(String.t()),
          list(String.t()),
          non_neg_integer(),
          non_neg_integer(),
          MapSet.t(),
          :a | :b
        ) :: {:finished | :loop, non_neg_integer(), non_neg_integer()}
  defp play_round([], [], cards_played, tricks, _seen_states, _starting_player) do
    {:finished, cards_played, tricks}
  end

  defp play_round([], _player_b, cards_played, tricks, _seen_states, _starting_player) do
    {:finished, cards_played, tricks}
  end

  defp play_round(_player_a, [], cards_played, tricks, _seen_states, _starting_player) do
    {:finished, cards_played, tricks}
  end

  defp play_round(player_a, player_b, cards_played, tricks, seen_states, starting_player) do
    # Check for loop detection - normalize decks (ignore number card values)
    state = normalize_state(player_a, player_b)

    if MapSet.member?(seen_states, state) do
      {:loop, cards_played, tricks}
    else
      seen_states = MapSet.put(seen_states, state)
      play_turn(player_a, player_b, [], cards_played, tricks, seen_states, starting_player)
    end
  end

  # Normalize state for loop detection - replace number cards with 'N'
  @spec normalize_state(list(String.t()), list(String.t())) ::
          {list(String.t()), list(String.t())}
  defp normalize_state(player_a, player_b) do
    {normalize_deck(player_a), normalize_deck(player_b)}
  end

  @spec normalize_deck(list(String.t())) :: list(String.t())
  defp normalize_deck(deck) do
    Enum.map(deck, fn card ->
      if card in ["J", "Q", "K", "A"], do: card, else: "N"
    end)
  end

  # Play a turn (alternating between players)
  @spec play_turn(
          list(String.t()),
          list(String.t()),
          list(String.t()),
          non_neg_integer(),
          non_neg_integer(),
          MapSet.t(),
          :a | :b
        ) :: {:finished | :loop, non_neg_integer(), non_neg_integer()}
  defp play_turn([], player_b, pile, cards_played, tricks, seen_states, :a) do
    # Player A is out of cards, Player B collects pile
    new_deck_b = player_b ++ Enum.reverse(pile)
    play_round([], new_deck_b, cards_played, tricks + 1, seen_states, :b)
  end

  defp play_turn(player_a, [], pile, cards_played, tricks, seen_states, :b) do
    # Player B is out of cards, Player A collects pile
    new_deck_a = player_a ++ Enum.reverse(pile)
    play_round(new_deck_a, [], cards_played, tricks + 1, seen_states, :a)
  end

  defp play_turn([card | rest_a], player_b, pile, cards_played, tricks, seen_states, :a) do
    new_pile = [card | pile]
    new_cards_played = cards_played + 1

    case card do
      card when card in ["J", "Q", "K", "A"] ->
        # Payment card played, opponent must pay penalty
        penalty = penalty_for_card(card)
        collect_penalty(rest_a, player_b, new_pile, new_cards_played, tricks, seen_states, :b, penalty)

      _ ->
        # Number card, pass turn to other player
        play_turn(rest_a, player_b, new_pile, new_cards_played, tricks, seen_states, :b)
    end
  end

  defp play_turn(player_a, [card | rest_b], pile, cards_played, tricks, seen_states, :b) do
    new_pile = [card | pile]
    new_cards_played = cards_played + 1

    case card do
      card when card in ["J", "Q", "K", "A"] ->
        # Payment card played, opponent must pay penalty
        penalty = penalty_for_card(card)
        collect_penalty(player_a, rest_b, new_pile, new_cards_played, tricks, seen_states, :a, penalty)

      _ ->
        # Number card, pass turn to other player
        play_turn(player_a, rest_b, new_pile, new_cards_played, tricks, seen_states, :a)
    end
  end

  # Collect penalty cards
  @spec collect_penalty(
          list(String.t()),
          list(String.t()),
          list(String.t()),
          non_neg_integer(),
          non_neg_integer(),
          MapSet.t(),
          :a | :b,
          non_neg_integer()
        ) :: {:finished | :loop, non_neg_integer(), non_neg_integer()}
  defp collect_penalty([], player_paying, pile, cards_played, tricks, seen_states, :a, _penalty) do
    # Player A (who should pay) is out of cards, Player B (opponent) collects pile
    new_deck_paying = player_paying ++ Enum.reverse(pile)
    play_round([], new_deck_paying, cards_played, tricks + 1, seen_states, :b)
  end

  defp collect_penalty(player_paying, [], pile, cards_played, tricks, seen_states, :b, _penalty) do
    # Player B (who should pay) is out of cards, Player A (opponent) collects pile
    new_deck_paying = player_paying ++ Enum.reverse(pile)
    play_round(new_deck_paying, [], cards_played, tricks + 1, seen_states, :a)
  end

  defp collect_penalty(player_a, [card | rest_b], pile, cards_played, tricks, seen_states, :b, penalty) when penalty > 0 do
    # Player B is paying penalty
    new_pile = [card | pile]
    new_cards_played = cards_played + 1

    case card do
      card when card in ["J", "Q", "K", "A"] ->
        # Payment card played during penalty, reverse roles
        new_penalty = penalty_for_card(card)
        collect_penalty(player_a, rest_b, new_pile, new_cards_played, tricks, seen_states, :a, new_penalty)

      _ ->
        # Number card, continue paying penalty
        collect_penalty(player_a, rest_b, new_pile, new_cards_played, tricks, seen_states, :b, penalty - 1)
    end
  end

  defp collect_penalty([card | rest_a], player_b, pile, cards_played, tricks, seen_states, :a, penalty) when penalty > 0 do
    # Player A is paying penalty
    new_pile = [card | pile]
    new_cards_played = cards_played + 1

    case card do
      card when card in ["J", "Q", "K", "A"] ->
        # Payment card played during penalty, reverse roles
        new_penalty = penalty_for_card(card)
        collect_penalty(rest_a, player_b, new_pile, new_cards_played, tricks, seen_states, :b, new_penalty)

      _ ->
        # Number card, continue paying penalty
        collect_penalty(rest_a, player_b, new_pile, new_cards_played, tricks, seen_states, :a, penalty - 1)
    end
  end

  defp collect_penalty(player_a, player_b, pile, cards_played, tricks, seen_states, :a, 0) do
    # Player A finished paying penalty with no interruption, Player B collects pile
    new_deck_b = player_b ++ Enum.reverse(pile)
    play_round(player_a, new_deck_b, cards_played, tricks + 1, seen_states, :b)
  end

  defp collect_penalty(player_a, player_b, pile, cards_played, tricks, seen_states, :b, 0) do
    # Player B finished paying penalty with no interruption, Player A collects pile
    new_deck_a = player_a ++ Enum.reverse(pile)
    play_round(new_deck_a, player_b, cards_played, tricks + 1, seen_states, :a)
  end

  @spec penalty_for_card(String.t()) :: 1..4
  defp penalty_for_card("J"), do: 1
  defp penalty_for_card("Q"), do: 2
  defp penalty_for_card("K"), do: 3
  defp penalty_for_card("A"), do: 4
end
