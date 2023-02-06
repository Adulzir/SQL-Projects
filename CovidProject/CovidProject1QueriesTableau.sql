/*
Queries used for Tableau Covid Project
*/

-- 1: Global Numbers of Death Percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ SUM(new_cases) * 100 as DeathPercentage
 FROM Project1.CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2;
 
 -- Create new table 
 CREATE TABLE CovidDeaths2 AS SELECT * FROM CovidDeaths;
-- Filter new table to exclude income values
SET SQL_SAFE_UPDATES = 0;
DELETE FROM Project1.CovidDeaths2 WHERE location IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income');
SET SQL_SAFE_UPDATES = 1;
 
 -- 2: Total Deaths per Continent
SELECT Location, SUM(new_deaths) as TotalDeathCount
FROM Project1.CovidDeaths2 
WHERE continent is null
and location not in ('world', 'European Union', 'International')
GROUP BY location
Order by TotalDeathCount desc;

-- 3: Percent Population Infected per Country
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
GROUP BY location, population 
Order by PercentofPopulationInfected desc;

-- 4: Percent Population Infected 
SELECT Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfected
FROM Project1.CovidDeaths
GROUP BY location, population, date
Order by PercentofPopulationInfected desc;






