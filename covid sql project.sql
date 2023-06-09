SELECT *
FROM PortfolioProject.dbo.covidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject.dbo.covidVacinations
ORDER BY 3,4

SELECT location, date ,total_cases,new_cases,total_deaths, population
FROM PortfolioProject.dbo.covidDeaths
ORDER BY 1,2


-- looking at total cases vs total deaths
SELECT location,date,total_cases,total_deaths,
	   CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 as death_percentage
FROM PortfolioProject.dbo.covidDeaths
WHERE location='Egypt'
ORDER BY 1,2

-- looking at total cases over population
SELECT location,date,total_cases,population,(total_cases / population)*100 as cases_percentage
FROM PortfolioProject.dbo.covidDeaths
WHERE location='Egypt'
ORDER BY 1,2

-- looking at countries with heighest infection rate compared to their population
SELECT location,population,
        MAX((total_cases / population)*100) as heighest_infect_count
FROM PortfolioProject.dbo.covidDeaths
GROUP BY location,population
ORDER BY 3 desc

--showing continents by highest death count compared to population
SELECT continent,
		MAX((CAST(total_deaths as float))) as death_percentage
FROM PortfolioProject.dbo.covidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY death_percentage desc

--showing countries by highest death count compared to population
SELECT location,		
	   MAX((CAST(total_deaths as int)/population)*100) as death_percentage
FROM PortfolioProject.dbo.covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY death_percentage desc

-- global numbers by days
SELECT date,		
	   Sum(new_cases) as total_cases,
	   sum(new_deaths) as sum_death,
	   (Sum(new_deaths)/sum(new_cases))*100
FROM PortfolioProject.dbo.covidDeaths
WHERE continent is not null AND new_cases !=0
GROUP BY date
order by date desc

--looking at total population vs vaccination
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
	   sum(convert(float,vac.new_vaccinations)) over (partition by dea.location
	   order by dea.location, dea.date) as people_vaccinated
FROM PortfolioProject.dbo.covidDeaths dea
Join PortfolioProject.dbo.covidVacinations vac
	ON dea.location =vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- using CTE
WITH pop_vs_vac(continent,location,date,population, new_vaccinations,people_vaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
	   sum(convert(float,vac.new_vaccinations)) over (partition by dea.location
	   order by dea.location, dea.date) as people_vaccinated
FROM PortfolioProject.dbo.covidDeaths dea
Join PortfolioProject.dbo.covidVacinations vac
	ON dea.location =vac.location
	and dea.date=vac.date
where dea.continent is not null
)
SELECT *,(people_vaccinated/population)*100 AS vac_percentage
FROM pop_vs_vac

-- USING TEMP TABLE
DROP TABLE IF EXISTS #percentTableVacs
CREATE TABLE #percentTableVacs
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)
INSERT INTO #percentTableVacs
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
	   sum(convert(float,vac.new_vaccinations)) over (partition by dea.location
	   order by dea.location, dea.date) as people_vaccinated
FROM PortfolioProject.dbo.covidDeaths dea
Join PortfolioProject.dbo.covidVacinations vac
	ON dea.location =vac.location
	and dea.date=vac.date
where dea.continent is not null

SELECT *,(people_vaccinated/population)*100 AS vac_percentage
FROM #percentTableVacs

--creating VIEW TO STORE DATA FOR LATER VISUALIZAION
CREATE VIEW percentTableVacs AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
	   sum(convert(float,vac.new_vaccinations)) over (partition by dea.location
	   order by dea.location, dea.date) as people_vaccinated
FROM PortfolioProject.dbo.covidDeaths dea
Join PortfolioProject.dbo.covidVacinations vac
	ON dea.location =vac.location
	and dea.date=vac.date
where dea.continent is not null




