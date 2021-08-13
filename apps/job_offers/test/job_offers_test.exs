defmodule JobOffersTest do
  use ExUnit.Case

  alias JobOffers.Jobs
  
  test "getting jobs offers groupped by continent" do
    {:ok, res} = Jobs.get_groupped_jobs_by_continents()

    assert res == %{
             "Africa" => %{
               "Admin" => 1,
               "Business" => 2,
               "Marketing / Comm'" => 1,
               "Retail" => 1,
               "TOTAL" => 8,
               "Tech" => 3
             },
             "Asia" => %{
               "Admin" => 1,
               "Business" => 26,
               "Marketing / Comm'" => 3,
               "Retail" => 6,
               "TOTAL" => 46,
               "Tech" => 10
             },
             "Europe" => %{
               "Admin" => 396,
               "Business" => 1371,
               "Conseil" => 175,
               "Créa" => 204,
               "Marketing / Comm'" => 759,
               "Retail" => 424,
               "TOTAL" => 4790,
               "Tech" => 1401,
               "unknown" => 60
             },
             "North America" => %{
               "Admin" => 9,
               "Business" => 27,
               "Créa" => 7,
               "Marketing / Comm'" => 12,
               "Retail" => 93,
               "TOTAL" => 163,
               "Tech" => 14,
               "unknown" => 1
             },
             "Oceania" => %{
               "Business" => 4,
               "Marketing / Comm'" => 1,
               "Retail" => 2,
               "TOTAL" => 8,
               "Tech" => 1
             },
             "South America" => %{"Business" => 4, "TOTAL" => 5, "Tech" => 1}
           }

    assert res["Asia"]["TOTAL"] == 46
  end
end
