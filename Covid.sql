Select *
From PortfollioProject..CovidDeath
where continent is not null
order by 3,4

Select *
From PortfollioProject..CovidVaccination
where continent is not null
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfollioProject..CovidDeath
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
From PortfollioProject..CovidDeath
where location like '%states'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date,  population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfollioProject..CovidDeath
where location like '%states'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

Select Location, Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfection
From PortfollioProject..CovidDeath
--where location like '%states'
group by Location, Population
order by PercentPopulationInfection desc

-- Showing Countries with Highest Death Count per Population
-- Convering the nvarchar to integer using 'cast'

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount 
From PortfollioProject..CovidDeath
where continent is not null -- to see accurate data
group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population 

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount 
From PortfollioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

-- Total cases, deaths and death percentage by day
Select date, SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int))as Total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfollioProject..CovidDeath
where continent is not null
group by date
order by 1,2

-- Count of total cases and death and the death percentage
Select  SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int))as Total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfollioProject..CovidDeath
where continent is not null
order by 1,2

-- Join two tables

select *
From PortfollioProject..CovidDeath dea
join PortfollioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total population vs Vaccianation

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
--, (
From PortfollioProject..CovidDeath dea
join PortfollioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
--, (
From PortfollioProject..CovidDeath dea
join PortfollioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated / Population) * 100
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
--, (
From PortfollioProject..CovidDeath dea
join PortfollioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *,(RollingPeopleVaccinated / Population) * 100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
From PortfollioProject..CovidDeath dea
join PortfollioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- Check the view

select *
From PercentPopulationVaccinated
