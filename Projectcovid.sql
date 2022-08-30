select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Vaccinations
--order by 3,4

--select data that we are going to be using
--Select Location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths
--order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerecentage
--from PortfolioProject..CovidDeaths
--where location like '%states%'
--order by 1,2


--looking at toal cases vs popluations
--shows what percentage of population got covid
Select Location, date, population,total_cases,  (total_cases/population)*100 as DeathPerecentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infextion rate compared to population
Select Location, population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercectPopulatedInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercectPopulatedInfected desc

--showing countries with highest death count per population
Select Location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by totaldeathcount desc

--let's break things down by continent

Select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by totaldeathcount desc

--showing the continitents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by totaldeathcount desc


--global numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage--total_deaths , (total_cases/total_cases)*100 as DeathPerecentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking total populatio vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..vaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--use cte
with PopvsVac (Continent, location, date,population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..vaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--temp table

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..vaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


--temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select * 
From PercentPopulationVaccinated
