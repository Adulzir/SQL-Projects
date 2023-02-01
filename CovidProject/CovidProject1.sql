/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * from Project1.CovidDeaths
WHERE continent is not null
ORDER BY 4,5;


-- Select the data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths,population
FROM Project1.CovidDeaths
WHERE continent is not null
ORDER BY 1,2;
 
 -- Total cases v Total deaths in the Unites States
 -- Shows likelihood of dying if you contract covid in the United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1.CovidDeaths
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2;
 
 -- Total cases vs Population in the Unites States
 -- Shows what percentage of the US population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
WHERE location like '%states%' AND continent is not null
Order by 1,2;
 
 -- Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
GROUP BY location, population 
Order by PercentofPopulationInfected desc;

-- Countries with Highest Death Count per Population
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM Project1.CovidDeaths
WHERE continent is not null
GROUP BY location, population 
Order by TotalDeathCount desc;

-- CONTINENT-CENTRIC QUERIES

-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Project1.CovidDeaths
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc;

 -- Showing continents with highest infection rate 
SELECT continent, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
GROUP BY continent
Order by PercentofPopulationInfected desc;
 
-- Showing the percentage of the population that contracted covid
SELECT continent, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
WHERE continent & total_Cases is not null
Order by 1,2;
 
 -- Showing the likelihood of death if you contract covid 
SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1.CovidDeaths
WHERE continent & total_cases is not null
ORDER BY 1,2;
 
 
 -- GLOBAL NUMBERS -- 
 -- Showing total cases, deaths, and death percentages per day 
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM Project1.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER by 1,2;
 
 -- Showing total cases, deaths, and death percentage of all time (dates: 
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ SUM(new_cases) * 100 as DeathPercentage
FROM Project1.CovidDeaths
WHERE continent is not null
ORDER BY 1,2;
 
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
 , SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Project1.CovidVaccinations dea
JOIN Project1.CovidDeaths vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent is not null
 
  -- Using CTE to perform Calculation on Partition By in previous query
 
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
 -- Total Population vs Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
 , SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Project1.CovidVaccinations dea
JOIN Project1.CovidDeaths vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent is not null
 )
SELECT *, (RollingPeopleVaccinated/Population) * 100 as PercentageVacPeople
FROM PopVsVac;
 
 -- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE Project1.PercentPopulationVaccinated (
Continent CHAR(255),
Location CHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
 , SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Project1.CovidVaccinations dea
JOIN Project1.CovidDeaths vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent is not null;

 
SELECT *, (RollingPeopleVaccinated/Population) * 100 as PercentageVacPeople
FROM PercenPopulationVaccinated ;
 
 -- Creating view to store data for later visualization
 
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
 , SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Project1.CovidVaccinations dea
JOIN Project1.CovidDeaths vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent is not null;

 
 SELECT *
 FROM PercentPopulationVaccinated;
 
 