defmodule Prism do
  @moduledoc """
  Computes the ordered prism IDs hit by a laser ray.

  The solver repeatedly finds the nearest prism lying on the current ray,
  updates the ray direction by adding the prism's refraction angle, and
  continues until no further prism is reachable.
  """

  @doc """
  Finds the sequence of prisms that the laser will hit.

  `start.angle` is interpreted in degrees.
  """

  # We use a small epsilon to account for floating point imprecision in the fixture data.
  # This allows us to consider a prism "hit" if it's very close to the ray, even if not perfectly aligned.
  # It also prevents immediately re-hitting the same prism at the current location.
  # The value of 0.2 is chosen based on the scale of the fixture coordinates and angles, and may be adjusted if needed.
  @epsilon 0.2

  @type location :: %{angle: number(), x: number(), y: number()}
  @type prisms :: [%{id: integer(), angle: number(), x: number(), y: number()}]

  @spec find_sequence(prisms :: prisms(), start :: location()) :: [integer()]
  def find_sequence(prisms, start), do: trace(prisms, normalize_location(start), [])

  defp trace(prisms, current_location, prism_sequence) do
    # 1) find the next prism on the ray, 2) build next state, 3) recurse.
    # Any non-hit result exits through `else` and returns the accumulated IDs.
    with {:found, next_prism} <- find_next_prism_hit(prisms, current_location),
         {:ok, next_location} <- build_next_location(current_location, next_prism) do
      trace(prisms, next_location, [next_prism.id | prism_sequence])
    else
      {:not_found} ->
        Enum.reverse(prism_sequence)
    end
  end

  defp find_next_prism_hit(prisms, current_location) do
    {dx, dy} = direction_vector(current_location.angle)
    ray = {dx, dy}

    prisms
    |> Enum.map(&project_prism_onto_ray(&1, current_location, ray))
    |> Enum.filter(&valid_hit?/1)
    |> Enum.min_by(&projection_distance/1, fn -> nil end)
    |> case do
      nil -> {:not_found}
      {prism, _t, _cross} -> {:found, prism}
    end
  end

  defp project_prism_onto_ray(prism, current_location, {dx, dy}) do
    # Vector from ray origin to candidate prism.
    vx = prism.x - current_location.x
    vy = prism.y - current_location.y

    # Dot product (`t`) is forward distance along the ray.
    # 2D cross product magnitude (`cross`) is perpendicular distance from ray.
    t = vx * dx + vy * dy
    cross = vx * dy - vy * dx

    {prism, t, cross}
  end

  # We accept a tolerance because fixture coordinates/angles are rounded decimals.
  # `t > @epsilon` also prevents immediately re-hitting the prism at current position.
  defp valid_hit?({_prism, t, cross}), do: t > @epsilon and abs(cross) < @epsilon

  defp projection_distance({_prism, t, _cross}), do: t

  defp build_next_location(current_location, next_prism) do
    # Refraction angle is relative to the current direction.
    {:ok,
     %{
       x: next_prism.x,
       y: next_prism.y,
       angle: normalize_angle(current_location.angle + next_prism.angle)
     }}
  end

  defp direction_vector(angle) do
    radians = angle * :math.pi() / 180.0
    {:math.cos(radians), :math.sin(radians)}
  end

  defp normalize_location(location), do: %{location | angle: normalize_angle(location.angle)}

  defp normalize_angle(angle) do
    normalized = :math.fmod(angle, 360.0)
    if normalized < 0.0, do: normalized + 360.0, else: normalized
  end
end
