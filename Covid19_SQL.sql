use Project_Covid19

select * from CovidDeaths 
order by 3,4

select * from CovidVaccinations 
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population  
from CovidDeaths order by 1,2


--Looking at total cases vs total deaths
--Likelihood of dying if contract with covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths 
--where location like 'India'
where continent is not null
order by 1,2



--Loking at total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as PositivePercentage
from CovidDeaths 
--where location like 'India'
where continent is not null
order by 1,2


--Looking Countries with highest Infection rates compared to population

select location, population, max(total_cases) as HigestInfectionCount, 
max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths 
--where location like 'India'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--Looking Countries with highest deaths count per population

select location, population, max(cast(total_deaths as bigint)) as TotalDeathCount
from CovidDeaths 
--where location like 'India'
where continent is not null
group by location, population
order by TotalDeathCount desc

--here our total_deaths column was in nvarchar datatype, need to cast to int
--also in location column continent name is given, need to remove that


--Looking data continent wise

select location, max(cast(total_deaths as bigint)) as TotalDeathCount
from CovidDeaths 
--where location like 'India'
where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc


--Global numbers by date

select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as bigint)) as TotalNewDeaths, 
(sum(cast(new_deaths as bigint))/sum(new_cases))*100 as NewDeathPercentage
from CovidDeaths 
where continent is not null
group by date
order by 1


select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as bigint)) as TotalNewDeaths, 
(sum(cast(new_deaths as bigint))/sum(new_cases))*100 as NewDeathPercentage
from CovidDeaths 
where continent is not null


select * from CovidVaccinations

select * 
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date

--Looking at total population vs vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 1,2,3

--Using partition

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) 
over (partition by d.location order by d.location, d.date) as RollingVaccinations 
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 1,2,3

--we cannot use alias for calculations, so we use cte or temp table
--No of columns in CTE must be equal to the columns present in table
--Order by clause cannot be used inside paranthesis


--Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) 
over (partition by d.location order by d.location, d.date) as RollingVaccinations 
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 1,2,3
)

Select *, (RollingVaccinations/population)*100 as PercentPopVaccinated
from PopvsVac
order by 1,2,3


--Temp Table


--drop table if exists #PercentPopulationVaccinated (if any alterations required)
create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingVaccinations numeric
)
Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) 
over (partition by d.location order by d.location, d.date) as RollingVaccinations 
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 1,2,3

Select *, (RollingVaccinations/population)*100 as PercentPopVaccinated
from #PercentPopulationVaccinated
order by 1,2,3


--Creating View to store data for Visualization

--drop view if exists PercentPopulationVaccinated

create view PercentPopVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) 
over (partition by d.location order by d.location, d.date) as RollingVaccinations 
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 1,2,3

select * from PercentPopVaccinated
order by 1,2,3




--Ctrl+Shift+C  for copying result with header
--Ctrl+H in excel for replacing null to 0


--SQL Queries for tableau

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
