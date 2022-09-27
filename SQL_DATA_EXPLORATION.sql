
SELECT *
FROM Portfolio_project..CovidDeaths
ORDER BY 3,4


--SELECT *
--  FROM Portfolio_project..CovidVaccinations
--ORDER BY 3,4

--These are some of the data we are going to use,
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project..CovidDeaths
ORDER BY 1, 2

--We are gonna be looking at Total Cases vs Total Deaths
--wORLD
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM Portfolio_project..CovidDeaths
ORDER BY 1, 2

--We are gonna be looking at Total Cases vs Total Deaths
--In India :
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE Location = 'India'
ORDER BY 1, 2

--We are gonna be looking at Total Cases vs Total Deaths
--In Canada:
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE Location = 'Canada'
ORDER BY 1, 2

--Looking at Total Cases vs Population
--In Canada, Shows what percentage of population got COVID
SELECT Location, date, Population, total_cases, (total_cases/population) * 100 AS ContractionRate_in_percentage
FROM Portfolio_project..CovidDeaths
WHERE Location = 'Canada'
ORDER BY 1, 2

--Looking at countries with Highest Infection rate compared to population:
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/Population)) * 100 AS InfectionPercentagePerPopulation
FROM Portfolio_project..CovidDeaths
--WHERE Location = 'Canada'
GROUP BY Location, Population
ORDER BY InfectionPercentagePerPopulation DESC

--showing Continents with highest death count per population
SELECT Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_project..CovidDeaths
--WHERE Location = 'Canada'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing countries with highest death count per population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_project..CovidDeaths
--WHERE Location = 'Canada'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS:
SELECT date, SUM(new_cases) AS GlobalNewCases, 
		SUM(CAST(new_deaths AS INT)) AS GlobalNewDeaths,
		(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM Portfolio_project..CovidDeaths
--WHERE Location = 'Canada'
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--GLOBAL NUMBERS: 
--total cases and death percentage:
SELECT SUM(new_cases) AS GlobalNewCases, 
		SUM(CAST(new_deaths AS INT)) AS GlobalNewDeaths,
		(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM Portfolio_project..CovidDeaths
--WHERE Location = 'Canada'
WHERE Continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--Joining the Covid_Vaccination and Covid_Death tables to find data

--Lookin at Total Population vs Vaccinations:
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, 
		VAC.new_vaccinations,
		SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100 ===> we cant use this column which we newly created. So, 
FROM Portfolio_project..CovidDeaths DEA
JOIN Portfolio_project..CovidVaccinations VAC 
	ON DEA.location = VAC.location 
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


--Now we have to make use of this new created column - with using two different methods: 

-- FIRST METHOD: Using CTE

WITH PopVSVacc (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS(
	SELECT DEA.continent, DEA.location, DEA.date, DEA.population, 
			VAC.new_vaccinations,
			SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
			--(RollingPeopleVaccinated/population)*100 ===> we cant use this column which we newly created. So, 
	FROM Portfolio_project..CovidDeaths DEA
	JOIN Portfolio_project..CovidVaccinations VAC 
		ON DEA.location = VAC.location 
		AND DEA.date = VAC.date
	WHERE DEA.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage FROM PopVSVacc

--SECOND METHOD: Using TEMP TABLE

DROP TABLE IF EXISTS #PopulationVaccinatedPercentage
CREATE TABLE #PopulationVaccinatedPercentage
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PopulationVaccinatedPercentage
	SELECT DEA.continent, DEA.location, DEA.date, DEA.population, 
				VAC.new_vaccinations,
				SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
				--(RollingPeopleVaccinated/population)*100 ===> we cant use this column which we newly created. So, 
		FROM Portfolio_project..CovidDeaths DEA
		JOIN Portfolio_project..CovidVaccinations VAC 
			ON DEA.location = VAC.location 
			AND DEA.date = VAC.date
		WHERE DEA.continent IS NOT NULL
		--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage FROM #PopulationVaccinatedPercentage



--CREATING A VIEW FOR LATER VISUALIZATIONS:

CREATE VIEW PopulationVaccinatedPercentage AS
	SELECT DEA.continent, DEA.location, DEA.date, DEA.population, 
					VAC.new_vaccinations,
					SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
					--(RollingPeopleVaccinated/population)*100 ===> we cant use this column which we newly created. So, 
			FROM Portfolio_project..CovidDeaths DEA
			JOIN Portfolio_project..CovidVaccinations VAC 
				ON DEA.location = VAC.location 
				AND DEA.date = VAC.date
			WHERE DEA.continent IS NOT NULL
			--ORDER BY 2,3

SELECT * FROM PopulationVaccinatedPercentage


