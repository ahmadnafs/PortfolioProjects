--Covid 19 Data Exploration

--Skills Used: Joins, CTE's, Temp table, Windows functions, Aggregate functions, Creating views, Creating data types

--Select the data we are starting with

Select * 
From PortfolioProject..Coviddeaths
Where Continent is not null
Order by 3,4

-- Showing total cases, total deaths and population
Select Location, Date, Total_cases, New_cases, Total_deaths, Population
From portfolioproject..coviddeaths
Order by 1,2

--Looking at total cases VS total deaths
--And the likelihood of a person dying after contacting covid in each country

Select Location, Date, Total_cases, Total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths
order by 1,2

--Looking at total cases VS population
--Shows what percentage of each country's population got covid

Select Location, Date, Total_cases, Population, (Total_cases/Population)*100 as CasesPercentage
From PortfolioProject..Coviddeaths
Order by 1,2

Select Location, Date, Total_cases, Population, (Total_cases/Population)*100 as CasesPercentage
From PortfolioProject..Coviddeaths
Where Location = 'Nigeria'
Order by 1,2

--Looking at countries with the highest infection rate compared to population

Select Location, Population, MAX(Total_cases) as HighestInfectionCount,
MAX((Total_cases/Population))*100 as HighestCasesPercentage
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by HighestCasesPercentage desc

--Showing countries with highest death count per population

Select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Location
Order by TotalDeathCount desc

--Breaking it down by continent

--Showing the continents with the highest death count per population

Select Continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Continent
Order by TotalDeathCount desc

--Global numbers
--Percentage of deaths per cases each day

Select Date, SUM(New_cases) as Overall_cases,
SUM(CAST(New_deaths as int)) as Overall_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Overall_DeathPercentage
From PortFolioProject..CovidDeaths
Where Continent is not null
Group by Date
Order by 1,2

--Overall death count percentage

Select SUM(New_cases) as Overall_cases,
SUM(CAST(New_deaths as int)) as Overall_deaths,
SUM(CAST(New_deaths as int))/SUM(new_cases)*100 as Overall_DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Using CTE to calculate

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
As rollingpeoplevaccinated
From portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From popvsVac

--TEMP TABLE

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
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
As rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View To Store Data For Later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
From portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated