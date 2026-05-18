defmodule NameBadge do
  def print(id, name, department) do
    department = if department, do: String.upcase(department), else: "OWNER"
    id = if id, do: "[#{id}] - ", else: ""

    id <> "#{name} - #{department}"
  end
end
