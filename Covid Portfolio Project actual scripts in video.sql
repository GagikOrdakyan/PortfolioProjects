
Select *
From PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Selecting Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Showing the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
WHERE location like '%states%'
order by 1,2


--Looking at total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationinfected
from PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
order by 1,2


--Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationinfected
from PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population 
order by PercentPopulationinfected desc


--Showing Countries with Highest Death Count per population


SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
--MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationinfected
from PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location 
order by TotalDeathCount desc


--Let's break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCountpercontinent
--MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationinfected
from PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent 
order by TotalDeathCountpercontinent desc


-- Showing continents with the highest death count per population

SELECT continent, population, MAX(cast(total_deaths as int)) AS TotalDeathCountPerContinent,
MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentDeathperContinent
from PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is null
GROUP BY continent, population
order by TotalDeathCountPerContinent desc

--Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
--MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentDeathperContinent
from PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY 
order by 1,2


-- Looking at total population vc Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(ISNULL(Convert(bigint, vac.new_vaccinations), 0)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Using CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(ISNULL(Convert(bigint, vac.new_vaccinations), 0)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From PopvsVac


--Temp Table 
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(ISNULL(Convert(bigint, vac.new_vaccinations), 0)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.Location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 1,2
	
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store Data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(ISNULL(Convert(bigint, vac.new_vaccinations), 0)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2


Select *
From PercentPopulationVaccinated







