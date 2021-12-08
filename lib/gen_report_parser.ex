defmodule GenReport.Parser do
  @months {
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  }

  def parse_file(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> format_line()
    |> List.update_at(3, fn month -> elem(@months, month - 1) end)
  end

  defp format_line([name, hours, day, month, year]) do
    [
      String.downcase(name),
      String.to_integer(hours),
      String.to_integer(day),
      String.to_integer(month),
      String.to_integer(year)
    ]
  end
end
