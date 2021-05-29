Select *
From ['Covid Deaths$']
where continent is not null
order by 3,4

--Select *
--From ['Covid Vaccinations$']
--order by 3,4

--Select Data we are going to be using

Select location, date, total_cases, new_cases,total_deaths,population
From ['Covid Deaths$']
order by 1,2

--Looking at Total Cases vs Total Deaths--
-- Shows the likelyhood of Dying if you contract Covid in your country -- 
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From ['Covid Deaths$']
Where location like'%ireland%'
order by 1,2


-- Looking at Total Cases vs Population --
--Shows what percentage of population got Covid--
Select location, date, population,total_cases,(total_cases/population)*100 as PopulationInfected
From ['Covid Deaths$']
--Where location like'%ireland%'
order by 1,2

--Looking at countries with highest infection rate compared to population--
Select location, population, MAX(total_cases)as HighestInfectionCount,Max((total_cases/population))*100 as HighestInfectionRate
From ['Covid Deaths$']
--Where location like'%ireland%'
Group by location, population
order by HighestInfectionRate desc


--Looking at countries with highest death death count per population--
Select location, population, MAX(cast (total_deaths as int))as HighestDeathRate
from ['Covid Deaths$']
--Where location like'%ireland%'
where continent is not null
Group by location, population
order by HighestDeathRate desc

--Breaking it down by continent--
Select location, MAX(cast (total_deaths as int))as HighestDeathRate
from ['Covid Deaths$']
--Where location like'%ireland%'
where continent is null
Group by location
order by HighestDeathRate desc

--Showing continents with highest death count--
Select continent, MAX(cast (total_deaths as int))as HighestDeathRate
from ['Covid Deaths$']
--Where location like'%ireland%'
where continent is not null
Group by continent
order by HighestDeathRate desc

--Global Numbers--
Select SUM(new_cases) as GlobalNewCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageOfCasesToDeaths
From ['Covid Deaths$']
--Where location like'%ireland%'
Where continent is not null
--Group by date
order by 1,2

--Joining Files--
Select *
From ['Covid Deaths$'] dea
Join ['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date

	-- Looking at Total Population vs Vaccination--
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,--(RollingPeopleVaccinated/population)*100,
From ['Covid Deaths$'] dea
Join ['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Use CTE--
With POPvsVAC (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From ['Covid Deaths$'] dea
Join ['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
From POPvsVAC

--TEMP TABLE--

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population Numeric,
New_vaccinations numeric,
RollingPeopleVaccinated Numeric
)


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From ['Covid Deaths$'] dea
Join ['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
From #PercentPopulationVaccinated

-- Create view to store data for later visualisations--
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From ['Covid Deaths$'] dea
Join ['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
from PercentPopulationVaccinated
