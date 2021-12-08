defmodule GenReport do
  alias GenReport.Parser

  @basereport %{
    "all_hours" => %{},
    "hours_per_month" => %{},
    "hours_per_year" => %{}
  }

  def build(file_name) do
    file_name
    |> Parser.parse_file()
    |> generate_report()
  end

  def build do
    {:error, "Insira o nome de um arquivo"}
  end

  defp generate_report(lines) do
    lines
    |> Enum.reduce(@basereport, fn line, report -> sum_values(line, report) end)
  end

  defp sum_values(
         [name, hours, _, key, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => hours_per_month,
           "hours_per_year" => hours_per_year
         }
       ) do
    all_hours = all_hours |> sum_hours(name, hours)

    hours_per_month =
      hours_per_month
      |> sum_total_hours_by_name_and_key(name, key, hours)

    hours_per_year =
      hours_per_year
      |> sum_total_hours_by_name_and_key(name, year, hours)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp sum_hours(hours_report, name, hours) do
    current_hours = Map.get(hours_report, name, 0)

    Map.put(hours_report, name, current_hours + hours)
  end

  def sum_total_hours_by_name_and_key(report, name, key, hours) do
    current_name_report = Map.get(report, name, %{})

    current_hours_report = sum_hours_by_key(current_name_report, hours, key)

    report
    |> Map.put(name, current_hours_report)
  end

  defp sum_hours_by_key(acc, hours, key) do
    acc
    |> Map.put(key, Map.get(acc, key, 0) + hours)
  end
end
