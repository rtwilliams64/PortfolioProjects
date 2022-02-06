SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY by 3,4

--Select the data that I will use 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Comparing total cases vs. total deaths
-- Shows the likelihood of dying if you contract COVID in your country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY by 1,2


-- Looking at total cases vs. population
-- shows what percentage of population contracted covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY by 1,2

--looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected desc

--shows countries with highest count per population 

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- group results by location

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeathCount desc


--  break results down by continent

--showing continents with the hightest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--globlal figures --  daily counts

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- global total figures

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- look at total population vs vaccinations

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths  dea
JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 1,2,3

--look at rolling totals of new vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  dea
JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 1,2,3


-- use CTE for percentage of population vs vaccinated people

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  dea
JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- use temp table for percentage of population vs vaccinated

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  dea
JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

-- create view of total population vs vaccinations

CREATE VIEW TotalpopVsVaccinations AS
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths  dea
JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null

SELECT *
FROM TotalpopVsVaccinations



-- create view to look at total cases vs. population in United States
-- shows what percentage of population contracted covid

CREATE VIEW USCasesVsUSPop AS
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'

SELECT *
FROM USCasesVsUSPop


--create view for looking at countries with highest infection rate compared to population

CREATE VIEW PercentagePopInfected AS
SELECT Location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
GROUP BY Location, Population

SELECT *
FROM PercentagePopInfected
ORDER BY PercentagePopulationInfected

--create view for percentage of the population vaccinated 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  dea
JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated





