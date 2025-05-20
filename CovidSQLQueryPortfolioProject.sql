SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..Covidvaccination$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in a certain country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%Kingdom%'
ORDER BY 1,2

--Looking at total cases vs population
--Shows percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%Kingdom%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfecionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%Kingdom%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with highest deathcount per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%Kingdom%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Lets break things down by continent
--Showing the continents with the highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%Kingdom%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers

SELECT Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%Kingdom%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs Vaccination
--CTE

WITH Popsvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
   SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covidvaccination$ vac
JOIN PortfolioProject..CovidDeaths$ dea
    ON vac.location = dea.location
    AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM Popsvsvac 


--TEMP table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
   SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covidvaccination$ vac
JOIN PortfolioProject..CovidDeaths$ dea
    ON vac.location = dea.location
    AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated

--Creating View to store data for later visualisation

CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
   SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covidvaccination$ vac
JOIN PortfolioProject..CovidDeaths$ dea
    ON vac.location = dea.location
    AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

