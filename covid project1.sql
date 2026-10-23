Select Location, date, total_cases, new_cases, total_deaths, population
From covidDeaths
order by 1, 2;

-- Looking at Total Cases vs Total deaths-- 

Select Location, date, total_cases, total_deaths
From coviddeaths
order by 1, 2;


-- Death percentage (Total Cases vs Total Deaths) --

SELECT location, date, total_cases, total_deaths,
       (total_deaths / total_cases) * 100 AS death_percentage
FROM portfolio_project.coviddeaths
WHERE location = 'India' AND continent IS NOT NULL
ORDER BY 1, 2;
  
-- Total cases vs population

SELECT location, date, population, total_cases,
	(total_cases / population) * 100 AS percent_population_infected
FROM portfolio_project.coviddeaths
WHERE location = 'India' AND continent IS NOT NULL
order by 1, 2;

-- Highest infection rate by country

SELECT location, population,
	MAX(total_cases) AS highest_infection_count,
    MAX((total_cases / population)) * 100 AS percent_population_infected
FROM  portfolio_project.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Highest death count by country 

SELECT location, MAX(total_deaths) AS  total_death_count
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
group by location
order by total_death_count DESC;

-- By continent

SELECT continent, MAX(total_deaths) AS  total_death_count
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
group by continent
order by total_death_count DESC;

--  GLOBAL NUMBERS -- 

SELECT
    `date`,
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS DECIMAL(18,2))) AS TotalNewDeaths,
    ROUND(
        SUM(CAST(new_deaths AS DECIMAL(18,2))) * 100.0
        / NULLIF(SUM(new_cases), 0),
        2
    ) AS DeathPercentage
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY `date`, TotalNewCases;


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS


SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeaths AS dea
JOIN portfolio_project.covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,  RollingPeopleVaccinated)
as 
(
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeaths AS dea
JOIN portfolio_project.covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac;


-- TEMP TABLE

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeaths AS dea
JOIN portfolio_project.covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- ORDER BY 2, 3

SELECT *,
       (RollingPeopleVaccinated / Population) * 100
FROM PercentPopulationVaccinated;



-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeaths AS dea
JOIN portfolio_project.covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;












