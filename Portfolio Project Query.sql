SELECT * FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4 

SELECT * FROM PortfolioProject..CovidVaccinations$
WHERE continent IS NOT NULL 
ORDER BY 3,4 

-- Look at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,new_cases,total_deaths,(total_deaths / total_cases )* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population has gotten COVID
SELECT Location, date, total_cases,population,(total_cases/population )* 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Total death count by continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Total death count by location
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Death percentages group by day ( variable name date )

SELECT date ,SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage  
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global Numbers
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage  
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations AS BIGINT)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS VaccinationCount
FROM PortfolioProject..CovidDeaths$ AS deaths
JOIN PortfolioProject..CovidVaccinations$ AS vaccinations
	ON deaths.location = vaccinations.location 
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent,Location,Date,Population,New_Vaccinations,VaccinationCount)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations AS BIGINT)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS VaccinationCount
--	,(VaccinationCount / population)*100
FROM PortfolioProject..CovidDeaths$ AS deaths
JOIN PortfolioProject..CovidVaccinations$ AS vaccinations
	ON deaths.location = vaccinations.location 
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL
)
SELECT * , (VaccinationCount/Population) * 100 AS VaccinationPercentage
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations AS BIGINT)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS VaccinationCount
FROM PortfolioProject..CovidDeaths$ AS deaths
JOIN PortfolioProject..CovidVaccinations$ AS vaccinations
	ON deaths.location = vaccinations.location 
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL

SELECT * , (VaccinationCount/Population) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated

-- TEMP TABLE 2
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations AS BIGINT)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS VaccinationCount
FROM PortfolioProject..CovidDeaths$ AS deaths
JOIN PortfolioProject..CovidVaccinations$ AS vaccinations
	ON deaths.location = vaccinations.location 
	AND deaths.date = vaccinations.date
--WHERE deaths.continent IS NOT NULL

SELECT * , (VaccinationCount/Population) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations AS BIGINT)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS VaccinationCount
FROM PortfolioProject..CovidDeaths$ AS deaths
JOIN PortfolioProject..CovidVaccinations$ AS vaccinations
	ON deaths.location = vaccinations.location 
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL


SELECT * FROM PercentPopulationVaccinated