SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select Data for use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying of Covid in your Country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
AND location like '%india%'
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of Populatin got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectionRate DESC

-- Showing Countries with Highest Death Rate
SELECT Location, MAX(cast(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Continents with the Highest Death Count
SELECT location, MAX(cast(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as INT)) as TotalDeaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--Total Population Vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE for Percentage of people vaccinated
WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, TotalPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (TotalPeopleVaccinated/Population)*100
FROM PopvsVac

--Alternative Temp Table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
TotalPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (TotalPeopleVaccinated/Population)*100 as VaccinationPercentage
FROM #PercentPopulationVaccinated

--Creating View For Visuaalisations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated