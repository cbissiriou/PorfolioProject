SELECT COUNT(*) FROM covidDeaths
SELECT COUNT(*) FROM covidVaccinations

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country
SELECT  location, date,total_cases,  total_deaths, (total_deaths  /total_cases)*100  as DeathPercentage
FROM covidDeaths
WHERE location LIKE '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT  location, date, population, total_cases, (total_cases/population)*100  as PopulationInfectionrate 
FROM covidDeaths
WHERE continent like '% %'
--WHERE location LIKE '%states%'
order by 1,2

select * from covidDeaths

-- Looking at countries whith highest infection rate compared to population

SELECT  location,  population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100  as Infectionrate 
FROM covidDeaths
WHERE continent like '% %'
Group by location, population
order by Infectionrate DESC


-- Showing countries with highest death count per population

SELECT  location, MAX(total_deaths) as HighestDeathCount
FROM covidDeaths
WHERE continent != ' '
Group by location
ORDER BY HighestDeathCount DESC

-- Let's break things down by continent
SELECT  continent,  MAX(total_deaths) as HighestDeathCount
FROM covidDeaths
WHERE continent != ' '
Group by continent
ORDER BY HighestDeathCount DESC


-- Showing continents with the highest death count per population

SELECT  continent,  MAX(total_deaths) as HighestDeathCount
FROM covidDeaths
WHERE continent != ' '
Group by continent
ORDER BY HighestDeathCount DESC

-- Global Numbers

SELECT   date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
CASE WHEN SUM(new_cases)=0 THEN 0 ELSE (CAST(SUM(new_deaths) AS FLOAT)/SUM(new_cases))*100 END  as DeathPercentage 
--IIF(SUM(new_cases)=0,0,(CAST(SUM(new_deaths) AS FLOAT)/SUM(new_cases)))*100  as DeathPercentage 
FROM covidDeaths
--WHERE continent like '% %'
Group by date


SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated

FROM covidDeaths D
JOIN covidVaccinations V ON D.date = V.date AND D.location = V.location
WHERE D.continent != ' '
ORDER BY 2,3


-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
	SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
	,SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
	FROM covidDeaths D
	JOIN covidVaccinations V ON D.date = V.date AND D.location = V.location
	WHERE D.continent != ' '
	--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PopvsVacPercentage
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVac
CREATE TABLE #PercentPopulationVac
(
	continent nvarchar(255)
	,location nvarchar(255)
	,date datetime
	,population numeric
	,new_vaccination numeric
	,RollingPeopleVaccinated numeric
)

INSERt INTO #PercentPopulationVac
	SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
	,SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
	FROM covidDeaths D
	JOIN covidVaccinations V ON D.date = V.date AND D.location = V.location
	WHERE D.continent != ' '
	--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/population)*100 AS PopvsVacPercentage
FROM #PercentPopulationVac

-- Creating view to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
	,SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
	FROM covidDeaths D
	JOIN covidVaccinations V ON D.date = V.date AND D.location = V.location
	WHERE D.continent != ' '
	
