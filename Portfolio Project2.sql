SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Number of Reported Cases vs Number of Reported Deaths 
SELECT location, date, total_cases, total_deaths, 
		(CAST(total_deaths AS decimal(12,2))/CAST(total_cases AS decimal(12,2)))*100 AS death_rate
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Mortality Rate in the United States_
SELECT location, date, total_cases, total_deaths, 
		(CAST(total_deaths AS decimal(12,2))/CAST(total_cases AS decimal(12,2)))*100 AS mortality_rate
FROM CovidDeaths
WHERE location like'%states%'
ORDER BY 1,2

--Infection Rate in the United States by Date
SELECT location, date, total_cases, population, 
		(CAST(total_cases AS decimal(12,2))/CAST(population AS decimal(12,2)))*100 AS infection_rate
FROM CovidDeaths
WHERE location like'%states%'
ORDER BY 1,2

--Infection Rate in the United States at Highest Point
SELECT location, MAX(total_cases) as highest_infection_rate, population, 
		MAX(CAST(total_cases AS decimal(12,2)))/MAX(CAST(population AS decimal(12,2)))*100 AS infection_rate
FROM CovidDeaths
WHERE location like'%states%'
GROUP BY location, population
ORDER BY 1,2


--Infection Rate by Country
SELECT location, MAX(total_cases) as total_number_cases, population, 
		MAX(CAST(total_cases AS decimal(12,2)))/MAX(CAST(population AS decimal(12,2)))*100 AS infection_rate
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY infection_rate DESC

--Total Number of Deaths by Country
SELECT location,
		MAX(CAST(total_deaths AS decimal(12,2)))AS total_number_deaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_number_deaths DESC


--Total Number of Deaths by Continent

SELECT continent,
		MAX(CAST(total_deaths AS decimal(12,2)))AS total_number_deaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_number_deaths DESC


--GLOBAL NUMBERS
--New Cases Worldwide by Date
SELECT date, SUM(new_cases) AS new_cases_per_day
FROM CovidDeaths
WHERE continent is not null
Group By date
ORDER BY 1,2

--Number of Vaccinations vs Total Population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vac_total 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac. date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE
WITH PopvsVac(continent,location,date,population, new_vaccinations,rolling_vac_total)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vac_total 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac. date
WHERE dea.continent is not null
)
Select *
FROM PopvsVac


WITH PopvsVac(continent,location,date,population, new_vaccinations,rolling_vac_total)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vac_total 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac. date
WHERE dea.continent is not null
)
Select *, (rolling_vac_total/population)*100 AS percentage_of_population_vaccinated
FROM PopvsVac


---Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vac_total numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vac_total 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac. date
WHERE dea.continent is not null
ORDER BY 2,3

Select *, (rolling_vac_total/population)*100 AS percentage_of_population_vaccinated
FROM #PercentPopulationVaccinated


--Creating View for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vac_total 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac. date
WHERE dea.continent is not null
