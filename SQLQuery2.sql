select *
from dbo.coviddeaths
order by 3,4 

----select *
----from dbo.covidvaccinations
----order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from dbo.coviddeaths
order by 1,2

-- Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from dbo.coviddeaths
order by 1,2

-- Let's look at what's going on in the US
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from dbo.coviddeaths
where location = 'United States'
order by 1,2

-- Let's look at my country, NEPAL

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from dbo.coviddeaths
where location = 'Nepal'
order by 1,2


select location, date, total_cases, population, (total_cases/population)*100 as 'What percentage of the population has covid?'
from dbo.coviddeaths
where location = 'United States'
order by 1,2

select location, date, total_cases, population, (total_cases/population)*100 as 'What percentage of the population has covid?'
from dbo.coviddeaths
where location = 'Nepal'
order by 1,2

-- What country has the highest infection rate?

select location, MAX(total_cases) as 'Highest Cases', population, max((total_cases/population))*100 as 'What is the percentage of the population infected with COVID?'
from dbo.coviddeaths
Group by population, location
order by 4 desc

-- Let's look at the countries with highest death count per population

select location, max(cast(total_deaths as int)) as 'Total Death Count'
from dbo.coviddeaths
Group By location
order by 2 desc

-- In the result, we are seeing the location such as 'world', 'upper middle income', Europe' and so on. By looking at the dataset, it has been found out that this needs fixed by adding where clause.

select location, max(cast(total_deaths as int)) as 'Total Death Count'
from dbo.coviddeaths
where continent is not NULL
Group By location
order by 2 desc


-- Let's compare wrt continent

select continent, max(cast(total_deaths as int)) as 'Total Death Count'
from dbo.coviddeaths
where continent is not NULL
Group By continent
order by 2 desc

 -- Let's look at Global Numbers

 select SUM(new_cases) as 'Total Cases', sum(cast(new_deaths as int)) as 'Total Deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Percentage of Deaths'
from dbo.coviddeaths
where continent is not null
order by 1,2

-- Let's start working on another table

select *
from dbo.covidvaccinations

-- Let's join these two tables together

select *
from dbo.coviddeaths dea
join dbo.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 

-- total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.coviddeaths dea
join dbo.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as Numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.coviddeaths dea
join dbo.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


-- USE CTE

with popvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.coviddeaths dea
join dbo.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select*, (RollingPeopleVaccinated/Population)*100
from popvsVac

-- Temp Table

Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.coviddeaths dea
join dbo.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*, (RollingPeopleVaccinated/Population)*100
from #PercentPeopleVaccinated


-- Create a view

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.coviddeaths dea
join dbo.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null






