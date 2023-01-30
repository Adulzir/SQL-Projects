SELECT * from Project1.CovidDeaths
WHERE continent is not null
ORDER BY 4,5;

 -- SELECT * from Project1.CovidVaccinations
 -- order by 4,5; 

-- Select the data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths,population
FROM Project1.CovidDeaths
WHERE continent is not null
ORDER BY 1,2;
 
 -- total cases v total deaths in the Unites States
 -- Shows likelihood of dying if you contract covid in the United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1.CovidDeaths
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2;
 
 -- total cases vs population in the Unites States
 -- Shows what percentage of the population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
WHERE location like '%states%' AND continent is not null
Order by 1,2;
 
 -- countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
GROUP BY location, population 
Order by PercentofPopulationInfected desc;

-- countries with highest covid death count per population
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM Project1.CovidDeaths
WHERE continent is not null
GROUP BY location, population 
Order by TotalDeathCount desc;

-- CONTINENT-CENTRIC QUERIES

-- continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Project1.CovidDeaths
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc;

 -- continents with highest infection rate 
SELECT continent, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
GROUP BY continent
Order by PercentofPopulationInfected desc;
 
-- percentage of the population on a continent got covid
SELECT continent, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
WHERE continent & total_Cases is not null
Order by 1,2;
 
 -- Likelihood of death if you contract covid in the United States
SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1.CovidDeaths
WHERE continent & total_cases is not null
ORDER BY 1,2;
 
 
 -- GLOBAL NUMBERS -- 
 -- total cases, deaths, and death percentages per day 
 Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
 FROM Project1.CovidDeaths
 WHERE continent is not null
 GROUP BY date
 ORDER by 1,2;
 
 -- total cases, deaths, and death percentage of all time (dates: 
 SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ SUM(new_cases) * 100 as DeathPercentage
 FROM Project1.CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2;
 
 
  -- USE CTE
 
 WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as (
 -- total population vs vaccination 
 SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
 , SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/dea.population) * 100
 FROM Project1.CovidVaccinations dea
 JOIN Project1.CovidDeaths vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
 WHERE dea.continent is not null
-- ORDER BY 2,3
 )
 SELECT *, (RollingPeopleVaccinated/Population) * 100 as PercentageVacPeople
 FROM PopVsVac;
 
-- TEMP TABLE

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
 -- , (RollingPeopleVaccinated/dea.population) * 100
 FROM Project1.CovidVaccinations dea
 JOIN Project1.CovidDeaths vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
 WHERE dea.continent is not null;
-- ORDER BY 2,3
 
SELECT *, (RollingPeopleVaccinated/Population) * 100 as PercentageVacPeople
 FROM PercenPopulationVaccinated ;
 
 -- Creatimg view to store data for later visualization
 
 DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated as 
 SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
 , SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/dea.population) * 100
 FROM Project1.CovidVaccinations dea
 JOIN Project1.CovidDeaths vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
 WHERE dea.continent is not null;
-- ORDER BY 2,3
 
 SELECT *
 FROM PercentPopulationVaccinated;
 
 