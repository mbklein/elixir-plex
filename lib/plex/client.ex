defmodule Plex.Client do
  @response_types %{
    ~r(^.+/xml\b) => :xml,
    ~r(^application/octet-stream) => :other
  }

  def get(path) do
    path
    |> build_url()
    |> HTTPoison.get()
    |> parse_response()
  end

  def build_url(path) do
    with config <- Plex.Config.config() do
      URI.parse(config.url)
      |> Map.put(:path, path)
      |> Map.put(:query, "X-Plex-Token=#{config.token}")
      |> URI.to_string()
    end
  end

  def parse_response({:ok, %{status_code: 200, body: body} = response}) do
    case response_type(response) do
      :xml -> SweetXml.parse(body)
      :other -> body
    end
  end

  defp parse_headers(%{headers: headers}) do
    headers
    |> Enum.map(fn {header, value} ->
      {
        header |> String.downcase() |> String.replace("-", "_") |> String.to_atom(),
        value
      }
    end)
    |> Enum.into(%{})
  end

  defp response_type(response) do
    with content_type <- response |> parse_headers() |> Map.get(:content_type) do
      @response_types
      |> Enum.find_value(fn {re, type} ->
        if Regex.match?(re, content_type), do: type, else: nil
      end)
    end
  end
end
