select *
from dbo.coviddeaths
order by 3,4


select *
from dbo.covidvaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,populations
from dbo.coviddeaths
order by 1,2
-- something i did to change the type of the column because when i try to but int i got an 0 answer in deaths percentage 
-- so i changed the type to float
alter table dbo.coviddeaths
alter column total_cases float

alter table dbo.coviddeaths
alter column total_deaths float

--looking at total cases vs total deaths
-- show likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
from dbo.coviddeaths
where location like '%netherlands%' and total_cases is not null
order by 1,2

-- Looking at total cases vs population 
-- show what percentage of population got covid 

select location,date,populations,total_cases,(total_cases/populations)*100 as PopulationPercentage
from dbo.coviddeaths
where location like '%netherlands%' and total_cases is not null
order by 1,2

-- looking ar countries with highest infection rate compared to population
select location,populations,Max(total_cases) as highestinfectioncount,max((total_cases/populations)*100) as PrecentofPopulationInfected
from dbo.coviddeaths
group by location,populations
order by PrecentofPopulationInfected desc

--showing the contintents with highest death count per population

select continent,max(cast(total_deaths as int)) as HighestNumberOfDeath
from dbo.coviddeaths
where continent is not null
group by continent
order by HighestNumberOfDeath desc

--showing Countries With Highest Death Count Per Population

select location,max(cast(total_deaths as int)) as HighestNumberOfDeath
from dbo.coviddeaths
where continent is not null
group by location
order by HighestNumberOfDeath desc

-- Global Numbers

select sum(new_cases) as totalcases,sum(new_deaths) as TotalDeaths,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from dbo.coviddeaths
where continent is not null 
order by 1,2

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.populations,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.coviddeaths as dea
join dbo.covidvaccinations as vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null and new_vaccinations is not null
order by 2,3 desc

--use cte

with popvsvac (continent,loction , date,poplation,RollingPeopleVaccinated,new_vaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.populations,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.coviddeaths as dea
join dbo.covidvaccinations as vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null and new_vaccinations is not null
)
select * ,(RollingPeopleVaccinated/poplation)*100
from popvsvac

--Temp table

create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.populations,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.coviddeaths as dea
join dbo.covidvaccinations as vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null and new_vaccinations is not null

select * ,(RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated


--creating view to store data for later visualization
go
--create view  
with cte as (
select	dea.continent,
		dea.location,
		dea.date,
		dea.populations,
		vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from dbo.coviddeaths as dea
join dbo.covidvaccinations as vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null and new_vaccinations is not null)


select * 
from cte