defmodule GenReport do
  alias GenReport.Parser

  @basereport %{
    "all_hours" => %{},
    "hours_per_month" => %{},
    "hours_per_year" => %{}
  }
  def build_from_many(file_names) when is_list(file_names) do
    file_names
    |> Task.async_stream(&build/1)
    |> Enum.reduce(@basereport, fn {:ok, result}, report -> sum_reports(result, report) end)
  end

  def build_from_many(file_names) when not is_list(file_names) do
    {:error, "Insira uma lista com os arquivos"}
  end

  def build(file_name) do
    file_name
    |> Parser.parse_file()
    |> generate_report()
  end

  def build do
    {:error, "Insira o nome de um arquivo"}
  end

  def sum_reports(
        %{
          "all_hours" => all_hours1,
          "hours_per_month" => hours_per_month1,
          "hours_per_year" => hours_per_year1
        },
        %{
          "all_hours" => all_hours2,
          "hours_per_month" => hours_per_month2,
          "hours_per_year" => hours_per_year2
        }
      ) do
    %{
      "all_hours" => sum_maps(all_hours1, all_hours2),
      "hours_per_month" => sum_nested_maps(hours_per_month1, hours_per_month2),
      "hours_per_year" => sum_nested_maps(hours_per_year1, hours_per_year2)
    }
  end

  defp sum_nested_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> sum_maps(value1, value2) end)
  end

  defp sum_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
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
