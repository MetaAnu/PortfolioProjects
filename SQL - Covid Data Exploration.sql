
---- DATA EXPLORATION IN SQL SERVER


SELECT *
FROM PortfolioProject..CovidDeaths;

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


-- SELECT DATA THAT WE ARE GOING TO BE USING

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total_cases vs Total_deaths
-- Show likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (Cast(total_deaths as int)/total_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'india'
ORDER BY 1,2
 
 
--- Looking at Total Cases vs Population
--- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'india'
ORDER BY 1,2

--- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'india'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC



-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount ---MAX((total_deaths/population))*100 AS TotalDeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'ind%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount ---MAX((total_deaths/population))*100 AS TotalDeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'ind%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount ---MAX((total_deaths/population))*100 AS TotalDeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'ind%'
WHERE continent is null
GROUP BY location 
ORDER BY TotalDeathCount DESC


-- Showing continents with the hightest death count 

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount ---MAX((total_deaths/population))*100 AS TotalDeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'ind%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

--Completion time: 2023-12-09T20:33:07.4622105+05:30

SELECT SUM(new_cases) AS total_cases , SUM(new_deaths)as total_deaths, SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage -- (CONVERT(float,total_deaths)/total_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'india'
WHERE continent is not null 
-- GROUP BY date
ORDER BY 1,2

--Error :Msg 8134, Level 16, State 1, Line 87
--Divide by zero error encountered.
--Warning: Null value is eliminated by an aggregate or other SET operation.

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--- (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	  and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


--- USE CTE

With PopsvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--- (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	  and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
Select * ,(RollingPeopleVaccinated/Population)*100 AS PercentagePeopleVaccinated
From PopsvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--- (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	  and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--- Creating views to store data for later visualizations

Create view 
PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--- (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	  and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated



