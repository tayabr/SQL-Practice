Select *
From PortfolioProject..CovidDeaths
Where continent is not null and where location = 
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total cases v. Total deaths
-- Shows likelihood of dying if you contract covid in USA
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at Total caes v. Population
-- Shows percentage of population that has been infected with Covid
Select location, date, population, total_cases, (total_cases/population)*100 AS covid_percentage
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
From PortfolioProject..CovidDeaths
group by location, population
order by percent_population_infected desc

-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by total_death_count desc

--Let's break things down by continent

Select location, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject..CovidDeaths
Where continent is null
AND location  NOT IN ('World', 'Upper middle income', 'High income', 'Lower middle income', 'European Union', 'Low income', 'International')
GROUP BY location
order by total_death_count desc

Select continent, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY continent
order by total_death_count desc

Select continent, location, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
group by location, continent
order by total_death_count desc

Select location, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject..CovidDeaths
Where continent is null
group by location
order by total_death_count desc

Select continent, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY continent
order by total_death_count desc

--Showing the continents with the highest death count THIS IS THE CONTINENT COUNT

Select continent, location, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject..CovidDeaths
Where continent is null
AND location  NOT IN ('World', 'Upper middle income', 'High income', 'Lower middle income', 'European Union', 'Low income', 'International')
GROUP BY location, continent
order by total_death_count desc

--Global numbers
Select date, sum(new_cases) AS total_cases, sum(cast(new_deaths as int)) AS total_deaths,
	sum(cast(new_deaths AS int))/sum(new_cases)*100 AS death_percentage
From PortfolioProject..CovidDeaths
WHERE continent is not null
group by date
order by 1,2

Select sum(new_cases) AS total_cases, sum(cast(new_deaths as int)) AS total_deaths,
	sum(cast(new_deaths AS int))/sum(new_cases)*100 AS death_percentage
From PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

--VACCINATIONS

Select *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

	--Looking at Total population v. vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_total_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
ORDER by 2, 3

-- USE CTE
With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_total_vaxxed)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_total_vaxxed
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
)
SELECT *, (rolling_total_vaxxed/population)*100
FROM pop_vs_vac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_total_vaxxed numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_total_vaxxed
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (rolling_total_vaxxed/population)*100
FROM #PercentPopulationVaccinated

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_total_vaxxed numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_total_vaxxed
--, (rolling_total_vaxxed/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (rolling_total_vaxxed/Population)*100
From #PercentPopulationVaccinated

--Creating view to store for later visualizations
DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_total_vaxxed
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

