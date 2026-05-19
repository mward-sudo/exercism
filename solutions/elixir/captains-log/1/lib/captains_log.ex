defmodule CaptainsLog do
  @planetary_classes ["D", "H", "J", "K", "L", "M", "N", "R", "T", "Y"]

  def random_planet_class() do
    Enum.random(@planetary_classes)
  end

  def random_ship_registry_number() do
    reg_number = :rand.uniform(8999) + 1000
    "NCC-#{reg_number}"
  end

  def random_stardate() do
    # Random float between 41_000.0 and 42_000.0
    :rand.uniform() * 1000.0 + 41_000.0
  end

  def format_stardate(stardate) do
    :erlang.float_to_list(stardate, [{:decimals, 1}]) |> List.to_string()
  end
end
