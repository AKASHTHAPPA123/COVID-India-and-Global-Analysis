SELECT * 
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY  3,4

SELECT * 
FROM portfolio_project.dbo.CovidVaccination
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2






--Total number of COVID-19 cases and deaths around the world
--overall the globe
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM portfolio_project..CovidDeaths 
WHERE continent is not NULL
ORDER BY 1,2


--for INDIA
SELECT location, date, total_cases, total_deaths,
(CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM portfolio_project..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2




--Total number of COVID-19 cases and deaths around the world
SELECT SUM(CAST(total_cases AS bigint)) TOTAL_CASES,
SUM(CAST(total_deaths AS bigint)) TOTAL_DEATHS,
(SUM(CAST(total_deaths AS float))/SUM(CAST(total_cases AS float)))*100 AS DeathPercentage
FROM portfolio_project..CovidDeaths





--Country with the highest infection rate compared to its total population
--OVERALL THE GLOBE
SELECT location, date, total_cases, population,
(CAST(total_cases AS float)/CAST(population AS float))*100 AS InfectionPercentage
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--FOR INDIA
SELECT location, date, total_cases, population,
(CAST(total_cases AS float)/CAST(population AS float))*100 AS InfectionPercentage
FROM portfolio_project..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2






--Percentage of the total population in each country infected with the virus
-- OVERALL THE GLOBE
SELECT location,MAX(total_cases) HighestInfectionRate, population,
MAX((CAST(total_cases AS float)/CAST(population AS float))*100) AS HighestInfectionPercentage
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC

-- FOR INDIA
SELECT location,MAX(total_cases) HighestInfectionRate, population,
MAX((CAST(total_cases AS float)/CAST(population AS float))*100) AS HighestInfectionPercentage
FROM portfolio_project..CovidDeaths
WHERE location like '%INDIA%'
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC






-- Country with the highest number of death cases
-- OVERALL THE GLOBE
SELECT location,MAX(total_deaths) HighestDeathRate, population,
MAX((CAST(total_deaths AS float)/CAST(population AS float))*100) AS HighestDeathPercentage
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathPercentage DESC

-- FOR INDIA
SELECT location,MAX(total_deaths) HighestDeathRate, population,
MAX((CAST(total_deaths AS float)/CAST(population AS float))*100) AS HighestDeathPercentage
FROM portfolio_project..CovidDeaths
WHERE location like '%INDIA%'
GROUP BY location, population
ORDER BY HighestDeathPercentage DESC







-- The total number of deaths in each continent
SELECT continent,SUM(CAST(total_deaths as int)) HighestDeathRate
FROM portfolio_project..CovidDeaths
WHERE continent IS not NULL 
GROUP BY continent
ORDER BY HighestDeathRate DESC


--Top 5 Asian countries with the highest number of deaths from COVID-19
SELECT top(5) location,SUM(CAST(total_deaths as int)) DeathRate
FROM portfolio_project..CovidDeaths
WHERE continent like '%ASIA%'
GROUP BY location
ORDER BY DeathRate DESC




--GLOBAL NUMBERS

--total death percentage
SELECT SUM(new_cases)  newcases,SUM(CAST(new_deaths as int)) deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 death_percentage
FROM portfolio_project..CovidDeaths 
WHERE new_deaths is not NULL
ORDER BY 1,2


--Number of people get infected per day from the virus vs Deaths per day
SELECT date, SUM(new_cases) as [newcases per day],SUM(CAST(new_deaths as int)) [deaths per day],
SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 [death percentage]
FROM portfolio_project..CovidDeaths 
WHERE new_deaths is not NULL
GROUP BY date
ORDER BY 1,2




SELECT * 
FROM portfolio_project..CovidDeaths deaths
join portfolio_project..CovidVaccination vac
	on deaths.location = vac.location
	and deaths.date = vac.date


-- Total population vs Vaccinations
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
from portfolio_project..CovidDeaths deaths
join portfolio_project..CovidVaccination vac
	on deaths.location = vac.location
	and deaths.date = vac.date
order by 2,3


--no. of people getting vaccination everyday
select	deaths.date, 
		deaths.continent, 
		deaths.location,
		deaths.population, 
		isnull(vac.new_vaccinations,0) as [Vaccinations per day], 
		sum(cast(isnull(vac.new_vaccinations,0) as bigint))
				over (partition by deaths.location order by deaths.date,deaths.location) as [count of vaccinated people]
from portfolio_project..CovidDeaths deaths
join portfolio_project..CovidVaccination vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
order by 2,3

--use CTE
with PopvsVac (date , continent, location , population, vaccinations, [count of vaccinated people])
as(
select	deaths.date, 
		deaths.continent, 
		deaths.location,
		deaths.population, 
		isnull(vac.new_vaccinations,0) as [Vaccinations per day], 
		sum(cast(isnull(vac.new_vaccinations,0) as bigint))
				over (partition by deaths.location order by deaths.date,deaths.location) as [count of vaccinated people]
from portfolio_project..CovidDeaths deaths
join portfolio_project..CovidVaccination vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
)
select location, population, vaccinations,[count of vaccinated people], ([count of vaccinated people]/population)*100 as [Vaccinated population]
from PopvsVac;

--TEMP table

create table #percentage_populatin_vaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
vaccinations numeric,
total_vaccinations numeric
)

insert into #percentage_populatin_vaccinated
select	deaths.date, 
		deaths.continent, 
		deaths.location,
		deaths.population, 
		isnull(vac.new_vaccinations,0) as [Vaccinations per day], 
		sum(cast(isnull(vac.new_vaccinations,0) as bigint))
				over (partition by deaths.location order by deaths.date,deaths.location) as [count of vaccinated people]
from portfolio_project..CovidDeaths deaths
join portfolio_project..CovidVaccination vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null



