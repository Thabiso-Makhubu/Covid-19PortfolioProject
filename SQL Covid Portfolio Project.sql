
--Covid 19 Data Exploration

--skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views,
--Converting Data Types


select *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--select *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Selecting Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

-- looking at total case vs total deaths
-- Shows likelyhood of dying if you get covid in country


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'South Africa'
where continent is not null
ORDER BY 1,2


--looking at total case vs population
-- Shows what percentage of population got covid 

select location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'South Africa'
where continent is not null
ORDER BY 1,2

--countries with highest infection rate compared to population

select location, population, MAX(total_cases) AS HighestInfectionCount, (Max(total_cases)/population)*100 AS PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
group by population, location
ORDER BY PopulationPercentageInfected DESC


--country with highest death count compared to Population

select location, MAX(cast(total_deaths as int)) AS TotaldeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
ORDER BY TotaldeathCount DESC

-- BREAK IT DOWN INTO CONTINENTS
-- The continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) AS TotaldeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
ORDER BY TotaldeathCount DESC

-- Global Numbers

select date, sum(new_cases) AS Total_Cases, sum(cast(new_deaths as int)) as Total_Death, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'South Africa'
where continent is not null
group by date
ORDER BY 1,2

select sum(new_cases) AS Total_Cases, sum(cast(new_deaths as int)) as Total_Death, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'South Africa'
where continent is not null
--group by date
ORDER BY 1,2


--- Total population vs Vaccinations
-- shows percentage of population that has recieved at least one Covid Vaccine

select dea. continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 1,2, 3

-- Using CTE to perform calculations on Partition By using the previous query


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea. continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2, 3
)

select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Using Temp Table to perform calculations on Partition By using the previous query

DROP TABLE IF EXISTS #PercentagePopulationVaccinated


create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea. continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--ORDER BY 2, 3

select *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated



-- CREATE VIEW TO STORE DATA FOR LATER VISUALISATION

Create View PercentagePopulationVaccinated as
select dea. continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2, 3


select * 
FROM PercentagePopulationVaccinated