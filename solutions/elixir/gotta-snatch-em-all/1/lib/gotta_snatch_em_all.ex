defmodule GottaSnatchEmAll do
  @moduledoc """
  A module for managing Blorkemon™️ card collections.

  This module provides functionality for creating and managing collections of cards,
  which are represented as MapSets to ensure uniqueness. It includes operations for:
  - Creating new collections
  - Adding and trading cards
  - Removing duplicates from card lists
  - Comparing collections (finding extra cards, common cards)
  - Counting unique cards across multiple collections
  - Splitting collections into shiny and regular cards
  """

  @type card :: String.t()
  @type collection :: MapSet.t(card())

  @doc """
  Creates a new collection containing a single card.

  ## Parameters
    - card: The card to add to the new collection

  ## Returns
    A MapSet containing the single card

  ## Examples
      iex> GottaSnatchEmAll.new_collection("Bleakachu")
      MapSet.new(["Bleakachu"])
  """
  @spec new_collection(card()) :: collection()
  def new_collection(card) do
    MapSet.new([card])
  end

  @doc """
  Adds a card to a collection.

  ## Parameters
    - card: The card to add
    - collection: The current collection

  ## Returns
    A tuple with:
    - A boolean indicating if the card was already in the collection
    - The updated collection with the card added

  ## Examples
      iex> GottaSnatchEmAll.add_card("Veevee", MapSet.new())
      {false, MapSet.new(["Veevee"])}

      iex> GottaSnatchEmAll.add_card("Veevee", MapSet.new(["Veevee"]))
      {true, MapSet.new(["Veevee"])}
  """
  @spec add_card(card(), collection()) :: {boolean(), collection()}
  def add_card(card, collection) do
    already_present = MapSet.member?(collection, card)
    updated_collection = MapSet.put(collection, card)
    {already_present, updated_collection}
  end

  @doc """
  Trades one of your cards for one of their cards.

  A trade is successful (returns true) only if:
  - You have the card you're trading away
  - You don't already have the card you're receiving

  ## Parameters
    - your_card: The card you're trading away
    - their_card: The card you're receiving
    - collection: Your current collection

  ## Returns
    A tuple with:
    - A boolean indicating if the trade is successful and worth doing
    - The collection after the trade (even if the trade wasn't successful)

  ## Examples
      iex> GottaSnatchEmAll.trade_card("Charilord", "Gyros", MapSet.new(["Charilord"]))
      {true, MapSet.new(["Gyros"])}

      iex> GottaSnatchEmAll.trade_card("Charilord", "Gyros", MapSet.new(["Gyros"]))
      {false, MapSet.new(["Gyros"])}
  """
  @spec trade_card(card(), card(), collection()) :: {boolean(), collection()}
  def trade_card(your_card, their_card, collection) do
    has_your_card = MapSet.member?(collection, your_card)
    has_their_card = MapSet.member?(collection, their_card)

    # Trade is successful only if you have your card and don't have their card
    trade_successful = has_your_card and not has_their_card

    # Update collection: remove your card, add their card
    updated_collection =
      collection
      |> MapSet.delete(your_card)
      |> MapSet.put(their_card)

    {trade_successful, updated_collection}
  end

  @doc """
  Removes duplicates from a list of cards and returns a sorted list.

  ## Parameters
    - cards: A list of cards that may contain duplicates

  ## Returns
    A sorted list of unique cards

  ## Examples
      iex> GottaSnatchEmAll.remove_duplicates(["Wigglycream", "Wigglycream"])
      ["Wigglycream"]

      iex> GottaSnatchEmAll.remove_duplicates(["Quarterpie", "Wigglycream", "Wigglycream"])
      ["Quarterpie", "Wigglycream"]
  """
  @spec remove_duplicates([card()]) :: [card()]
  def remove_duplicates(cards) do
    cards
    |> MapSet.new()
    |> MapSet.to_list()
    |> Enum.sort()
  end

  @doc """
  Counts how many cards you have that the other collection doesn't have.

  ## Parameters
    - your_collection: Your card collection
    - their_collection: Another person's card collection

  ## Returns
    The number of cards you have that they don't have

  ## Examples
      iex> GottaSnatchEmAll.extra_cards(MapSet.new(["Shazam", "Cooltentbro"]), MapSet.new(["Shazam"]))
      1

      iex> GottaSnatchEmAll.extra_cards(MapSet.new(["Shazam"]), MapSet.new(["Shazam"]))
      0
  """
  @spec extra_cards(collection(), collection()) :: non_neg_integer()
  def extra_cards(your_collection, their_collection) do
    your_collection
    |> MapSet.difference(their_collection)
    |> MapSet.size()
  end

  @doc """
  Finds cards that appear in all collections (the intersection).

  ## Parameters
    - collections: A list of card collections

  ## Returns
    A sorted list of cards that appear in every collection

  ## Examples
      iex> GottaSnatchEmAll.boring_cards([MapSet.new(["Shazam", "Veevee"]), MapSet.new(["Shazam", "Gyros"])])
      ["Shazam"]

      iex> GottaSnatchEmAll.boring_cards([MapSet.new(["Shazam"]), MapSet.new(["Gyros"])])
      []
  """
  @spec boring_cards([collection()]) :: [card()]
  def boring_cards(collections) do
    case collections do
      [] ->
        []
      [first | rest] ->
        rest
        |> Enum.reduce(first, fn collection, acc ->
          MapSet.intersection(acc, collection)
        end)
        |> MapSet.to_list()
        |> Enum.sort()
    end
  end

  @doc """
  Counts the total number of unique cards across all collections.

  ## Parameters
    - collections: A list of card collections

  ## Returns
    The total count of unique cards across all collections

  ## Examples
      iex> GottaSnatchEmAll.total_cards([MapSet.new(["Shazam"]), MapSet.new(["Gyros", "Shazam"])])
      2

      iex> GottaSnatchEmAll.total_cards([MapSet.new(["Shazam"]), MapSet.new(["Shazam"])])
      1
  """
  @spec total_cards([collection()]) :: non_neg_integer()
  def total_cards(collections) do
    collections
    |> Enum.reduce(MapSet.new(), fn collection, acc ->
      MapSet.union(acc, collection)
    end)
    |> MapSet.size()
  end

  @doc """
  Splits a collection into shiny cards and regular cards.

  Shiny cards are those that start with the string "Shiny ".

  ## Parameters
    - collection: A card collection

  ## Returns
    A tuple with two sorted lists:
    - A list of shiny cards (cards starting with "Shiny ")
    - A list of regular cards (all other cards)

  ## Examples
      iex> GottaSnatchEmAll.split_shiny_cards(MapSet.new(["Shiny Hitmonchuck", "Blasturtle"]))
      {["Shiny Hitmonchuck"], ["Blasturtle"]}

      iex> GottaSnatchEmAll.split_shiny_cards(MapSet.new(["Blasturtle", "Zumbat"]))
      {[], ["Blasturtle", "Zumbat"]}
  """
  @spec split_shiny_cards(collection()) :: {[card()], [card()]}
  def split_shiny_cards(collection) do
    collection
    |> Enum.split_with(fn card -> String.starts_with?(card, "Shiny ") end)
    |> then(fn {shiny, regular} ->
      {Enum.sort(shiny), Enum.sort(regular)}
    end)
  end
end
