SELECT *
FROM PortfolioCovid..CovidDeath
ORDER BY 1,2

-- Total cases vs total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeath
WHERE Location LIKE '%Zea%'
ORDER BY 1,2

-- Total cases vs population in NZ
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeath
WHERE Location LIKE '%Zea%'
ORDER BY 1,2

-- Countries with highest infection rate compare to population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

-- Country with highest death count per population
SELECT Location, MAX(CAST(total_deaths as int)) AS Max_total_death
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Max_total_death DESC

-- Continent with highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) AS Max_total_death
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Max_total_death DESC

--Global total death, total case, chance by date
SELECT date, SUM(total_cases) as total_case, SUM(CAST(total_deaths AS int)) as total_death, SUM(CAST(total_deaths AS int)) / SUM(total_cases) * 100 as percentage_of_infected
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1 DESC

--Global total death, total case, chance
SELECT SUM(total_cases) as total_case, SUM(CAST(total_deaths AS int)) as total_death, SUM(CAST(total_deaths AS int)) / SUM(total_cases) * 100 as percentage_of_infected
FROM CovidDeath
WHERE continent IS NOT NULL
--ORDER BY 1,2 DESC

--population VS vaccinations
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS People_vaccinated
FROM CovidDeath dea
JOIN CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- percentage population vacvinated
WITH VacVSPop(Continent, 
	Location, 
	Date, 
	Population, 
	New_vaccinations,
	Rolling_people_vaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rolling_people_vaccinated
FROM CovidDeath dea
JOIN CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (Rolling_people_vaccinated/population)*100 AS percentage_population_vactinated
FROM VacVSPop
ORDER BY 2,3

--Tabtable1
SELECT 
	SUM(new_cases) AS total_case,
	SUM(CAST(new_deaths AS INT)) AS total_death,
	SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS death_percentage
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2

--TabTable2
SELECT
	location,
	SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM CovidDeath
WHERE continent IS NULL
	AND location NOT IN ('World','European Union', 'International')
GROUP BY location
ORDER BY 2 DESC;

--TabTable3
SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection,
	MAX((total_cases/population)) * 100 AS percent_pop_infected
FROM CovidDeath
GROUP BY location, population
ORDER BY 4 DESC;

--TabTable4
SELECT
	location,
	population,
	date,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_pop_infected
FROM CovidDeath
GROUP BY location, population, date
ORDER BY 5 DESC

--Create View for later visualization
CREATE VIEW PopVSVac AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS People_vaccinated
FROM CovidDeath dea
JOIN CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PopVSVac
ORDER BY 2,3;


CREATE VIEW TCaseVSPopNZ
AS
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeath
WHERE Location LIKE '%Zea%'
--ORDER BY 1,2