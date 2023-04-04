SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--order by 3,4

--SELECT DATA THAT WE ARE GOING TO USE

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
order by 3,4

--LOOKING FOR TOTAL CASES VS TOTAL DEATH
--SHOW LIKIHOOD IF YOU GET COVID IN YOUR COUNTRY
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
order by 3,4

--LOOKING TOTAL CASES VS POPULATION
--SHOW WHAT PORCENTAGE OF PEOPLE GET COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulation
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
order by 3,4

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location LIKE '%state%'
group by location, population
order by PercentPopulationInfected desc

--SHOWING COUNTRIES WITH HIGHES DEATH COUNT PER POLULATION
SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent is not null
group by location, population
order by TotalDeathCount desc


--BREAKE THINGS DOWN BY CONTINENT


--SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent is not null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT 	SUM(new_cases) as total_cases, 
		SUM(cast(new_deaths as int)) as total_deaths, 
		SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
--group by date
order by 1,2


--LOOKING AT TOTAL POPULATION VS VACCINATION
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVacccinated/population)*100

FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--USE CTE

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , RollingPeopleVacccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3
)

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--	TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , RollingPeopleVacccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
-- order by 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATE VIEW TO STORE DATE FOR LATER VISUALIZATION

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , RollingPeopleVacccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3