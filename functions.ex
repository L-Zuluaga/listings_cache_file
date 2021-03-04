defmodule Cache.Functions do
  def extract_listings_data_cbl() do
    ## Build function to
    {:ok, file} = File.read(Path.expand("./cbl-2016-2018.json"))

    {:ok, decoded_file} = Jason.decode(file)

    first_half =
      decoded_file
      |> Map.get("values")
      |> Enum.map(fn [id, title, address, number, mls] ->
        %{
          "#{id}" => %{
            "title" => title || "",
            "address" => "#{number} #{address}",
            "mls" => mls || ""
          }
        }
      end)

    {:ok, file2} = File.read(Path.expand("./cbl-2019-2021.json"))
    {:ok, decoded_file2} = Jason.decode(file2)

    second_half =
      decoded_file2
      |> Map.get("values")
      |> Enum.map(fn [id, title, address, number, mls] ->
        %{
          "#{id}" => %{
            "title" => title || "",
            "address" => "#{number} #{address}",
            "mls" => mls || ""
          }
        }
      end)

    parsed_listings = Enum.concat(first_half, second_half)

    {:ok, file} = File.read("#{@cache_url}/listings_data.json")
    {:ok, decoded_cache} = Jason.decode(file)

    ## USEFULL LOGS.
    decoded_cache
    |> Map.get("Coldwell Banker Luxury")
    |> Enum.count()
    |> IO.inspect(label: "OLD COUNT:")

    Enum.count(parsed_listings)
    |> IO.inspect(label: "NEW COUNT:")

    ###############
    json_file =
      decoded_cache
      |> Map.replace("Coldwell Banker Luxury", parsed_listings)
      |> Jason.encode!()

    File.write("#{@cache_url}/listings_data.json", json_file)
  end

  def extract_listings_data(externalFile, cacheCompanyName) do
    ## Build function to
    {:ok, file} = File.read(Path.expand("./#{externalFile}.json"))

    {:ok, decoded_file} = Jason.decode(file)

    parsed_listings =
      decoded_file
      |> Map.get("values")
      |> Enum.map(fn [id, title, address, number, mls] ->
        %{
          "#{id}" => %{
            "title" => title || "",
            "address" => "#{number} #{address}",
            "mls" => mls || ""
          }
        }
      end)

    {:ok, file} = File.read("#{@cache_url}/listings_data.json")
    {:ok, decoded_cache} = Jason.decode(file)

    ## USEFULL LOGS.
    decoded_cache
    |> Map.get(cacheCompanyName)
    |> Enum.count()
    |> IO.inspect(label: "OLD COUNT:")

    Enum.count(parsed_listings)
    |> IO.inspect(label: "NEW COUNT:")

    ###############
    json_file =
      decoded_cache
      |> Map.replace(cacheCompanyName, parsed_listings)
      |> Jason.encode!()

    File.write("#{@cache_url}/listings_data.json", json_file)
  end
end
