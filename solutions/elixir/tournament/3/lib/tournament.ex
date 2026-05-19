defmodule Tournament.TeamRecord do
  @moduledoc """
  A record of a team's performance in a tournament.
  """

  @enforce_keys [:name]
  defstruct name: "",
            matches_played: 0,
            wins: 0,
            draws: 0,
            losses: 0,
            points: 0

  @type t :: %__MODULE__{
          name: String.t(),
          matches_played: non_neg_integer(),
          wins: non_neg_integer(),
          draws: non_neg_integer(),
          losses: non_neg_integer(),
          points: non_neg_integer()
        }

  @type result :: :win | :draw | :loss

  @spec new(name :: String.t()) :: t()
  def new(name), do: %__MODULE__{name: name}

  def add_match_result(%__MODULE__{} = team_record, result) do
    %__MODULE__{
      team_record
      | matches_played: team_record.matches_played + 1,
        wins: team_record.wins + count_result(result, :win),
        draws: team_record.draws + count_result(result, :draw),
        losses: team_record.losses + count_result(result, :loss),
        points: team_record.points + points_for(result)
    }
  end

  @spec to_list(t()) :: list(String.t())
  def to_list(team_record) do
    [
      team_record.name,
      to_string(team_record.matches_played),
      to_string(team_record.wins),
      to_string(team_record.draws),
      to_string(team_record.losses),
      to_string(team_record.points)
    ]
  end

  defp count_result(a, a), do: 1
  defp count_result(_, _), do: 0

  defp points_for(:win), do: 3
  defp points_for(:draw), do: 1
  defp points_for(:loss), do: 0
end

defmodule Tournament.ColumnFormat do
  @moduledoc """
  Specifies the width and alignment of a column in a table.
  """

  @enforce_keys [:width, :align]
  defstruct width: 0, align: :left

  @type t :: %__MODULE__{width: non_neg_integer(), align: align()}
  @type align :: :left | :right
end

defmodule Tournament.Formatter do
  alias Torunament.Table

  @moduledoc """
  Specifies the behaviour for formatting a table of data.
  """
  @typep table :: Table.t()

  @callback format(table :: table()) :: Binary.t()

  defmacro __using__(_) do
    quote do
      @behaviour Tournament.Formatter
    end
  end
end

defmodule Tournament.TableFormatter do
  @moduledoc """
  Formats a table of data as a string.
  """

  alias Tournament.Table
  use Tournament.Formatter

  @impl Tournament.Formatter
  def format(table) do
    [table.header_titles | Table.to_list(table)]
    |> Enum.map_join("\n", &format_row(&1, table.column_formats))
  end

  defp format_row(row, column_formats) do
    Enum.zip(row, column_formats)
    |> Enum.map_join(" | ", &format_cell/1)
  end

  defp format_cell({value, %{width: width, align: :left}}),
    do: value <> String.duplicate(" ", width - String.length(value))

  defp format_cell({value, %{width: width, align: :right}}),
    do: String.duplicate(" ", width - String.length(value)) <> value
end

defmodule Torunament.Result do
  @moduledoc """
  Specifies the result of a match.
  """

  @type t :: :win | :draw | :loss
end

defmodule Tournament.MatchResult do
  @moduledoc """
  Specifies the result of a match between two teams.
  """

  alias Tournament.Result

  @enforce_keys [:team1, :team2, :result]
  defstruct team1: "", team2: "", result: :win

  @type t :: %__MODULE__{
          team1: String.t(),
          team2: String.t(),
          result: Result.t()
        }

  @spec new(team1 :: String.t(), team2 :: String.t(), result :: Result.t()) :: t()
  def new(team1, team2, result) when result in [:win, :loss, :draw] do
    %__MODULE__{team1: team1, team2: team2, result: result}
  end

  def new(_, _, _), do: nil

  def new_from_string(string, opts \\ []) do
    delimeter = Keyword.get(opts, :delimeter, ";")

    case String.split(string, delimeter) do
      [team1, team2, result] -> new(team1, team2, result_string_to_atom(result))
      _ -> nil
    end
  end

  defp result_string_to_atom("win"), do: :win
  defp result_string_to_atom("loss"), do: :loss
  defp result_string_to_atom("draw"), do: :draw
  defp result_string_to_atom(_), do: nil
end

defmodule Tournament.TeamResult do
  @moduledoc """
  Specifies the result of a match for a team, or a list of two teams results
  using new_from_match_result()
  """
  alias Tournament.MatchResult

  @typep match_result :: MatchResult.t()

  @enforce_keys [:team, :result]
  defstruct team: "", result: :win

  @type t :: %__MODULE__{
          team: String.t(),
          result: result()
        }
  @type result :: :win | :draw | :loss

  @spec new(team :: String.t(), result :: Result.t()) :: t() | nil
  def new(team, result) when result in [:win, :loss, :draw] do
    %__MODULE__{team: team, result: result}
  end

  def new(_, _), do: nil

  @spec new_from_match_result(match_result :: match_result()) :: [t() | nil]
  def new_from_match_result(%{team1: team1, team2: team2, result: result}) do
    [
      %__MODULE__{team: team1, result: result},
      %__MODULE__{team: team2, result: opposite_result(result)}
    ]
  end

  @spec opposite_result(result :: result()) :: result()
  defp opposite_result(:win), do: :loss
  defp opposite_result(:loss), do: :win
  defp opposite_result(:draw), do: :draw
end

defmodule Tournament.Table do
  @moduledoc """
  Represents a table of teams and their stats based on results.
  """

  alias Tournament.ColumnFormat
  alias Tournament.{TeamRecord, TeamResult}

  @header_titles ~w(Team MP W D L P)
  @column_formats [
    %ColumnFormat{width: 30, align: :left},
    %ColumnFormat{width: 2, align: :right},
    %ColumnFormat{width: 2, align: :right},
    %ColumnFormat{width: 2, align: :right},
    %ColumnFormat{width: 2, align: :right},
    %ColumnFormat{width: 2, align: :right}
  ]

  defstruct rows: [], header_titles: @header_titles, column_formats: @column_formats

  @type t :: %__MODULE__{
          rows: [team_record()],
          header_titles: [String.t()],
          column_formats: [%Tournament.ColumnFormat{}]
        }

  @typep team_record :: TeamRecord.t()
  @typep result :: TeamResult.result()
  @typep team_result :: TeamResult.t()

  @spec new :: t()
  def new do
    %__MODULE__{}
  end

  @spec new_from_team_results([team_result()]) :: t()
  def new_from_team_results(team_results) do
    table = Enum.reduce(team_results, new(), &update_with_team_result/2)

    sorted_rows =
      Enum.sort(
        table.rows,
        fn
          row1, row2 when row1.points != row2.points -> row1.points >= row2.points
          row1, row2 -> row1.name <= row2.name
        end
      )

    Map.put(table, :rows, sorted_rows)
  end

  @spec to_list(t()) :: [[String.t()]]
  def to_list(table) do
    Enum.map(table.rows, &TeamRecord.to_list/1)
  end

  @spec update_with_team_result(team_result(), t()) :: t()
  defp update_with_team_result(team_result, table) do
    case Enum.find(table.rows, &(&1.name == team_result.team)) do
      nil ->
        new_table = add_new_team_record(table, team_result.team)
        update_with_team_result(team_result, new_table)

      team_record ->
        Map.update!(
          table,
          :rows,
          &Enum.map(
            &1,
            fn
              ^team_record -> update_team_record(team_record, team_result.result)
              other -> other
            end
          )
        )
    end
  end

  @spec add_new_team_record(t(), String.t()) :: t()
  defp add_new_team_record(table, team) do
    Map.put(table, :rows, table.rows ++ [%TeamRecord{name: team}])
  end

  @spec update_team_record(team_record :: team_record(), result :: result()) :: team_record()
  defp update_team_record(team_record, result) do
    Tournament.TeamRecord.add_match_result(team_record, result)
  end
end

defmodule Tournament do
  @moduledoc """
  A module for calculating the results of a football tournament.
  """

  alias Tournament.{MatchResult, Table, TableFormatter, TeamResult}

  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """
  @spec tally(input :: list(String.t())) :: String.t()
  def tally([]), do: TableFormatter.format(%Table{})

  def tally(input) do
    input
    |> Enum.map(&MatchResult.new_from_string/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&TeamResult.new_from_match_result/1)
    |> List.flatten()
    |> Table.new_from_team_results()
    |> TableFormatter.format()
  end
end
