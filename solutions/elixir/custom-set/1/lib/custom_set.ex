defmodule CustomSet do
  @opaque t :: %__MODULE__{map: map()}

  defstruct map: %{}

  @spec new(Enum.t()) :: t
  def new(enumerable) do
    %__MODULE__{map: Map.new(enumerable, &{&1, true})}
  end

  @spec empty?(t) :: boolean
  def empty?(%__MODULE__{map: map}), do: map_size(map) == 0

  @spec contains?(t, any) :: boolean
  def contains?(%__MODULE__{map: map}, element), do: Map.has_key?(map, element)

  @spec subset?(t, t) :: boolean
  def subset?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    Enum.all?(map1, fn {key, _} -> Map.has_key?(map2, key) end)
  end

  @spec disjoint?(t, t) :: boolean
  def disjoint?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    not Enum.any?(map1, fn {key, _} -> Map.has_key?(map2, key) end)
  end

  @spec equal?(t, t) :: boolean
  def equal?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    Map.equal?(map1, map2)
  end

  @spec add(t, any) :: t
  def add(%__MODULE__{map: map} = set, element) do
    %{set | map: Map.put(map, element, true)}
  end

  @spec intersection(t, t) :: t
  def intersection(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    %__MODULE__{map: Map.take(map1, Map.keys(map2))}
  end

  @spec difference(t, t) :: t
  def difference(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    %__MODULE__{map: Map.drop(map1, Map.keys(map2))}
  end

  @spec union(t, t) :: t
  def union(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    %__MODULE__{map: Map.merge(map1, map2)}
  end
end
