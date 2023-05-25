select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

select Location, date, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Total cases vs Total Deaths
--shows likelihood of dying.
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

--Looking at total cases vs population
select Location, date, total_cases,population, (total_cases/population)*100 as PercentagePolupationInfected
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

--Looking at countries with highest infection rate
select Location, MAX(total_cases), population, MAX(total_cases/population)*100 as PercentagePolupationInfected
from PortfolioProject..CovidDeaths
group by location,population 
order by PercentagePolupationInfected desc


--Showing countries with the highest death count per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
select date, SUM(new_cases) as Total_Cases_on_that_day,SUM(cast(new_deaths as int)) as Total_deaths_on__that_day
, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Joined the two table
select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.date = vac.location
   and dea.date = vac.date

--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE
with PopvsVac(continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated





--Creating a view to store data for visualization

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated

