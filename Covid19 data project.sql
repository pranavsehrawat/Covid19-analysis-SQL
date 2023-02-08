use PortfolioProject


--SELECT * FROM PortfolioProject..covidDeaths
--order by 3,4


SELECT * 
FROM PortfolioProject..covidDeaths
where continent is not null
order by 3,4



--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..covidDeaths
where location like '%india%'
and continent is not null
order by 1,2



--looking at the total cases vs population
--shows what percentage of total people got covid

select location,date, population, total_cases ,(total_cases/population)*100 as percentageAffected
from PortfolioProject..covidDeaths
where location like '%india%'
order by 1,2


-- all the country names listed
--select distinct location
--from PortfolioProject..covidDeaths
--order by 1


--looking at countries with highest infection rate compared to population
select location, population , max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as percentPopulationInfected
from PortfolioProject..covidDeaths
where continent is not null
group by location, population
order by percentPopulationInfected desc
--order by HighestInfectionCount desc


--looking at countries with highest death count
select location, max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- among continents
select location, max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is null and location not like '%income%'
group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS (the total cases, total deaths that came up on that particular day)
select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where continent is not null
group by date
order by 1


--ABSOLUTE GLOBAL NUMBER OF CASES OVERALL of the total data
select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where continent is not null
--group by date
order by 1


--..........................................................
--..........................................................
--..........................................................

--LOOKING AT THE VACCINATIONS TABLE
select *
from PortfolioProject..covidVaccinations
order by 3,4


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (PARTITION by dea.location order by dea.location, dea.date) as TotalVaccinationstillthatDate --, (TotalVaccinationstillthatDate/population)*100 as vaccinationPercentage
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3





--using CTE (common table expression)
with POPvsVAC (Continent, location, date, population, new_vaccinations, TotalVaccinationstillthatDate) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (PARTITION by dea.location order by dea.location, dea.date) as TotalVaccinationstillthatDate --, (TotalVaccinationstillthatDate/population)*100 as vaccinationPercentage
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (TotalVaccinationstillthatDate/POPULATION)*100
FROM POPvsVAC




-- Using Temp Tables...
Drop table if exists #PercentPopulationVaccinated    --(because it shows errors if the table is made once)
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
totalvaccinationstillthatdate numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (PARTITION by dea.location order by dea.location, dea.date) as TotalVaccinationstillthatDate --, (TotalVaccinationstillthatDate/population)*100 as vaccinationPercentage
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (TotalVaccinationstillthatDate/POPULATION)*100 --as PercentVaccinated_till_that_date
from #PercentPopulationVaccinated




-- Creating a View for later Visualizations
Create View TotalDeathCountView as
select location, max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by location
--order by TotalDeathCount desc


create view view1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (PARTITION by dea.location order by dea.location, dea.date) as TotalVaccinationstillthatDate --, (TotalVaccinationstillthatDate/population)*100 as vaccinationPercentage
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null


select * from view1



