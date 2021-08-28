SELECT *
FROM DataProject1..COVIDDeaths
ORDER BY 3,4 --column positions

--SELECT *
--FROM DataProject1..COVIDVaccinations
--ORDER BY 3,4

--SELECTING BY COUNTRY- Location
--Selecting columns needed

SELECT 
	location 
	,date
	,total_cases
	,new_cases
	,total_deaths
	,population
FROM DataProject1..COVIDDeaths
ORDER BY 1,2

--Getting percentage of death cases from total cases
--Likelihood of death in Kenya and Democratic Republic of Congo
SELECT 
	location 
	,date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases)*100 AS Death_percentage
FROM DataProject1..COVIDDeaths
WHERE total_deaths IS NOT NULL
	OR location = 'Kenya'
	OR location LIKE '%democratic%' --for displaying two conditions
ORDER BY 1,2

--Explore total cases vs population in Kenya
--Shows what population has gotten COVID
SELECT 
	location 
	,date
	,population
	,total_cases 
	,(total_cases/population)*100 AS Infection_percentage
FROM DataProject1..COVIDDeaths
WHERE location = 'Kenya'
ORDER BY 2

--Countries with the highest infection rates 
SELECT 
	location 
	,population
	,total_cases AS HighestInfectionCount
	,(total_cases/population)*100 AS Infection_percentage
FROM DataProject1..COVIDDeaths
ORDER BY Infection_percentage DESC

--Countries with Highest death count per population
SELECT 
	location 
	,MAX(CAST (total_deaths AS int)) AS TotalDeathCount
FROM DataProject1..COVIDDeaths
WHERE continent IS NOT NULL --removes continent names from continent column from location
GROUP BY location
ORDER BY TotalDeathCount DESC

--SELECTING BY CONTINENT
--CONTINENTS with Highest death count per population

SELECT 
	continent 
	,MAX(CAST (total_deaths AS int)) AS TotalDeathCount
FROM DataProject1..COVIDDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Get the total number of GLOBAL Numbers 
SELECT 
	date
	,SUM(CAST(new_cases AS int)) AS TotalNewCases
	,SUM(CAST(new_deaths AS int)) AS TotalNewDeaths
	,SUM(CAST(new_deaths AS int))/SUM(CAST(new_cases AS int))*100 AS NewDeathPercentages
FROM DataProject1..COVIDDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2


-- Total location VS Vaccination

SELECT 
	dea.continent
	,dea.location
	--,dea.date
	,dea.population
	,vac.new_vaccinations 
	,SUM (CONVERT (int,vac.new_vaccinations))--CONVERT can be used in place of CAST AS 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --partition rows of table into groups
	--,(RollingPeopleVaccinated/population)*100
FROM DataProject1..COVIDDeaths dea
JOIN DataProject1..COVIDVaccinations vac --joins the two tables
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent IS NOT NULL --all columns must have new table alias before it
ORDER BY 2,3

--USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations 
	,SUM (CONVERT (int,vac.new_vaccinations))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM DataProject1..COVIDDeaths dea
JOIN DataProject1..COVIDVaccinations vac 
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3 --order by cannot be used in CTE
)

SELECT 
	*
	,(RollingPeopleVaccinated/population)*100
FROM PopVsVac


--USE TEMP TABLE

--DROP Table if exists #PercentagePopulationVaccinated --add when making alterations
CREATE Table #PercentagePopulationVaccinated
(
	Continent nvarchar(255)
	,Location nvarchar(255)
	,Date datetime
	,Population numeric
	,New_vaccination numeric
	,RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated --# is used to indicate temporary
SELECT 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations 
	,SUM (CONVERT (int,vac.new_vaccinations))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM DataProject1..COVIDDeaths dea
JOIN DataProject1..COVIDVaccinations vac 
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3 

SELECT 
	*
	,(RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated



--CREATE VIEW FOR LATER VISUALIZATION

CREATE View PercentagePopulationVaccinated AS
SELECT 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations 
	,SUM (CONVERT (int,vac.new_vaccinations))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM DataProject1..COVIDDeaths dea
JOIN DataProject1..COVIDVaccinations vac 
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3 

SELECT *
FROM PercentagePopulationVaccinated
