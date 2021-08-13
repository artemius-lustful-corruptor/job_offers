defmodule JobOffersServiceWeb.OffersControllerTest do
  use JobOffersServiceWeb.ConnCase

  # TODO fix this tests, border region, entity match

  test "getting nearest offers", %{conn: conn} do
    res =
      get(conn, "/jobs/offers/filter?lat=48.8659387&lon=2.34532&radius=1")
      |> json_response(200)

    assert res == [
      %{
        "category_name" => "Tech",
        "contract_type" => "FULL_TIME",
        "distance" => 0.34,
        "name" => "Développement Backend",
        "office_latitude" => "48.865906",
        "office_longitude" => "2.3455685",
        "profession_id" => "13"
      },
      %{
        "category_name" => "Tech",
        "contract_type" => "INTERNSHIP",
        "distance" => 0.34,
        "name" => "Gestion de Projet / Produit",
        "office_latitude" => "48.865906",
        "office_longitude" => "2.3455685",
        "profession_id" => "12"
      },
      %{
        "category_name" => "Business",
        "contract_type" => "INTERNSHIP",
        "distance" => 0.34,
        "name" => "Relation client / Support",
        "office_latitude" => "48.865906",
        "office_longitude" => "2.3455685",
        "profession_id" => "10"
      },
      %{
        "category_name" => "Marketing / Comm'",
        "contract_type" => "INTERNSHIP",
        "distance" => 0.34,
        "name" => "Communication / Création",
        "office_latitude" => "48.865906",
        "office_longitude" => "2.3455685",
        "profession_id" => "3"
      },
      %{
        "category_name" => "Tech",
        "contract_type" => "FULL_TIME",
        "distance" => 0.34,
        "name" => "Développement Fullstack",
        "office_latitude" => "48.865906",
        "office_longitude" => "2.3455685",
        "profession_id" => "16"
      },
      %{
        "category_name" => "Créa",
        "contract_type" => "INTERNSHIP",
        "distance" => 0.34,
        "name" => "Production audiovisuelle",
        "office_latitude" => "48.865906",
        "office_longitude" => "2.3455685",
        "profession_id" => "27"
      }
    ]

    assert length(res) == 6
  end

  test "find jobs near saint-petersburg", %{conn: conn} do
    res =
      get(conn, "/jobs/offers/filter?lat=59.9311&lon=30.3609&radius=1")
      |> json_response(200)

    assert length(res) == 0

    [o | _] =
      get(conn, "/jobs/offers/filter?lat=59.9311&lon=30.3609&radius=1500")
      |> json_response(200)

    assert %{
             "category_name" => "Business",
             "contract_type" => "FULL_TIME",
             "distance" => 1202.305,
             "name" => "BizDev / Vente",
             "office_latitude" => "47.322132",
             "office_longitude" => "5.0397629",
             "profession_id" => "2"
           } = o
  end

  test "negative radius", %{conn: conn} do
    lat = 43.1332
    lon = 131.9113

    res =
      get(conn, "/jobs/offers/filter?lat=#{lat}&lon=#{lon}&radius=-3000")
      |> json_response(200)

    assert res == []
  end
end
