SELECT * 
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


SELECT *
FROM PortfolioProjects..CovidVaccinations
ORDER BY 3,4;


-- Select Data that we are going to be using


SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Comparing the Total Cases vs Total Deaths 


SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	ROUND(((total_deaths/total_cases)*100),2) AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Comparing the Total Cases vs Population
--Shows the population's proportion with covid


SELECT 
	location,
	date,
	population,
	total_cases,
	ROUND(((total_cases/population)*100),2) AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population


SELECT 
	continent,
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	ROUND(MAX((total_cases/population)*100),2) AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY continent, PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population


SELECT 
	continent,
	location,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY continent, TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Continents With the Highest Death Count per Population


SELECT 
	continent,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS


SELECT 
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--GLOBAL NUMBERS PER DAY


SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations


SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE


WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) AS (
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, ROUND((RollingPeopleVaccinated/population)*100,2)
FROM PopvsVac


--CREATING A TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ROUND((RollingPeopleVaccinated/population)*100,2)
FROM #PercentPopulationVaccinated


--Creating Views to Store Data for Visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated