defmodule CaptainsLog do
  @planetary_classes ["D", "H", "J", "K", "L", "M", "N", "R", "T", "Y"]

  def random_planet_class() do
    Enum.random(@planetary_classes)
  end

  def random_ship_registry_number() do
    reg_number = Enum.random(1000..9999)
    "NCC-#{reg_number}"
  end

  def random_stardate() do
    # Random float between 41_000.0 and 42_000.0
    :rand.uniform() * 1000.0 + 41_000.0
  end

  def format_stardate(stardate) do
    #  1. Use :io_lib.format convert the stardate to one decimal place
    #  2. Convert the charlist to a binry string
    stardate
    |> then(&:io_lib.format("~.1f", [&1]))
    |> List.to_string()
  end
end
