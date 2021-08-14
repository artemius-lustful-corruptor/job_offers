# This tech task for some Russian outsources company

You will find enclosed 2  csv files with data for that task: https://drive.google.com/drive/folders/1b9VnNTsnLBQrX6aScLxuFQDY1yW26SBG?usp=sharing 
- 1/ A list of a few thousands of job offers:

    _profession_id,contract_type,name,office_latitude,office_longitude   
    2,FULL_TIME,Dev Full Stack,48.8768868,2.3091203_

- 2/ A list of “professions” (cf. “profession_id” above):
    _id,name,category_name
    16,Développement Fullstack,Tech_

# EXERCISES / QUESTIONS
> 01 / 03 . Exercise: Continents grouping  
  Using the previous data, your goal is to develop a script  
  which will return the count of job offers per profession category per continent.
	
> 02 / 03 . Question: Scaling ?  
Now, let’s imagine we have 100 000 000 job offers in our database, and 1000 new job offers  
 per second (yeah, it’s a lot coming in!). What do you implement if we want the same output  
 than in the previous exercise in real-time?  
NB: no code necessary for this question

> 03 / 03 . Exercise: API implementation
						
_Now, we would like those data to become usable! The goal of this exercise is to develop an API with a single endpoint which will allow to get the previous job offers around a given location (through coordinates) and a given radius around this location (eg: 50km).
Query parameters for this endpoint:
latitude (eg: 48.8659387)
longitude (eg: 2.34532)
radius (eg: 10 (km))
In the output, we want the list of job offers corresponding to the previous search criteria.
Also, if you’re able to mention the proximity of the job offers to the defined coordinates, it would be obviously a plus!_


# My implementation
This repository contains the umbrella phoenix project with two applications.  
The first is the job_offers. That app represent the exercise #1.  
The second application is the job_offers_service. That application represent the exercise #2.  

# Run the job_offers app
```
cd apps/job_offers/
iex -S mix run
iex(1)> JobOffers.Jobs.distribute_by_continent
```
The result of that function is:  
```
{:ok,
 %{
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
 }}
```
# Run job_offers_service

```
cd apps/job_offers_service/
mix phx.server
[info] Access JobOffersServiceWeb.Endpoint at http://localhost:4000
```
Go to the browser at _http://localhost:4000/jobs/offers/filter?lat=48.8659387&lon=2.34532&radius=1_  
The response of that request is: 
```
[
   {
      "category_name":"Tech",
      "contract_type":"FULL_TIME",
      "distance":0.34,
      "name":"Développement Backend",
      "office_latitude":"48.865906",
      "office_longitude":"2.3455685",
      "profession_id":"13"
   },
   {
      "category_name":"Tech",
      "contract_type":"INTERNSHIP",
      "distance":0.34,
      "name":"Gestion de Projet / Produit",
      "office_latitude":"48.865906",
      "office_longitude":"2.3455685",
      "profession_id":"12"
   },
   {
      "category_name":"Business",
      "contract_type":"INTERNSHIP",
      "distance":0.34,
      "name":"Relation client / Support",
      "office_latitude":"48.865906",
      "office_longitude":"2.3455685",
      "profession_id":"10"
   },
   {
      "category_name":"Marketing / Comm'",
      "contract_type":"INTERNSHIP",
      "distance":0.34,
      "name":"Communication / Création",
      "office_latitude":"48.865906",
      "office_longitude":"2.3455685",
      "profession_id":"3"
   },
   {
      "category_name":"Tech",
      "contract_type":"FULL_TIME",
      "distance":0.34,
      "name":"Développement Fullstack",
      "office_latitude":"48.865906",
      "office_longitude":"2.3455685",
      "profession_id":"16"
   },
   {
      "category_name":"Créa",
      "contract_type":"INTERNSHIP",
      "distance":0.34,
      "name":"Production audiovisuelle",
      "office_latitude":"48.865906",
      "office_longitude":"2.3455685",
      "profession_id":"27"
   }
]
```

# The response for exercise #2 

I can suggest two solutions for that tech task. Firstly we can improve the current algorithm with ets tables, and concurently handle batches of database data. For example we can store the jobs offers in the ets tables per continent, and store that tables in the genserver’s state.  But for a big genserver’s state, I think, we need to store results of data processing in the database.  Sometimes periodically delete old records with some other genserver in background. And when new job offers come to the server, we can immediately filter that data in the background, for example with Elixir.Task. The receiving results will modify ets tables in the main genserver’s state.

Secondly we can create two new tables in the database. The user's offers an application table that contains results as a association with Reuslt table as a `has many relationship` and the finish flag for data processing, and `result calculation` table. That application;s table and result;s table are in **one to many relationships**. Application has many results. So, when the user trying to get job offers in the database creates an application record and receives the application_id  to the client back.  Data processing start in background. Periodically the client will fetch the data processing results until the application’s finish flag turns on. With that solution we give our clients the ability to consume small pieces of data during data processing without waiting. Of course in that solution we can use previous suggestions with the additional genservers and ets tables for vertical scaling.


# The posible improvements  

1. Use PostGis to store and calculate geographic data
2. Use the table_rex library to represent text table for exercise #1
3. Unload the tests logic
4. Adding more concurency to build genserver stage
