
-- Reviewing the Covid Deaths Data

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4;


-- Selecting the Data that we are going to be using. 

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
ORDER BY 
	1, 2 


-- Looking at total cases vs. total deaths 
-- Shows the likelihood of dying if you contract Covid in the United States. 

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage  
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	location = 'United States' 
	AND continent is not null
ORDER BY 
	1, 2 

-- Looking at the Total Cases vs. Populations 
-- Shows what percentage of population have Covid 

SELECT 
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 AS percent_population_infected
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	Location like 'United States' 
	AND continent is not null
ORDER BY 
	1, 2 

-- What countries have the highest infection rates? 

SELECT 
	continent, 
	population, 
	MAX(total_cases) AS highest_infection_count, 
	MAX((total_cases/population))*100 AS percent_population_infected
FROM 
	PortfolioProject..CovidDeaths 
WHERE 
	continent is not null
GROUP BY 
	location, 
	population
ORDER BY 
	percent_population_infected desc

-- Breaking things down by continent 


-- Which continent have the highest death count per population? 

SELECT 
	continent, 
	MAX(cast(total_deaths as int)) AS total_death_count 
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
GROUP BY 
	continent
Order BY 
	total_death_count DESC

-- Which continent have the highest death count? 

SELECT 
	location, 
	MAX(cast(total_deaths as int)) AS total_death_count 
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is null
GROUP BY 
	location
Order BY 
	total_death_count DESC


-- Global Numbers per day

SELECT 
	date, 
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as INT)) as total_deaths,
	SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE 
	continent is not null
GROUP BY
	date
ORDER BY 
	1, 2 

-- Global numbers for the world

SELECT 
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths as INT)) as total_deaths,
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE 
	continent is not null
ORDER BY 
	1, 2 


-- Looking at Total Population vs Vaccinations

SELECT 
	deaths.continent, 
	deaths.location,
	deaths.date,
	deaths.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY deaths.location 
		ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject..CovidDeaths deaths
	JOIN  PortfolioProject..CovidVaccinations vac
		ON deaths.location = vac.location 
		AND deaths.date = vac.date
WHERE 
	deaths.continent is not null 
ORDER BY 
	2, 3 

-- Showing how to use a CTE.

With 
	PopvsVac 
	(continent, 
	location, 
	date, 
	population, 
	new_vaccinations, 
	rolling_people_vaccinated)
AS(
SELECT 
	deaths.continent, 
	deaths.location,
	deaths.date,
	deaths.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY deaths.location 
		ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject..CovidDeaths deaths
	JOIN  PortfolioProject..CovidVaccinations vac
		ON deaths.location = vac.location 
		AND deaths.date = vac.date
WHERE 
	deaths.continent is not null) 

SELECT 
	*, (rolling_people_vaccinated/population)*100
FROM 
	PopvsVac



-- Example TEMP Table

DROP Table If exists 
	#Percent_Population_Vaccinated 
CREATE TABLE 
	#Percent_Population_Vaccinated 
	(continent nvarchar(255), 
	location nvarchar (255),
	date datetime, 
	population numeric, 
	new_vaccinations numeric, 
	rolling_people_vaccinated numeric) 
Insert Into 
	#Percent_Population_Vaccinated
SELECT 
	deaths.continent, 
	deaths.location,
	deaths.date,
	deaths.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY deaths.location 
		ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject..CovidDeaths deaths
	JOIN  PortfolioProject..CovidVaccinations vac
		ON deaths.location = vac.location 
		AND deaths.date = vac.date
WHERE 
	deaths.continent is not null 


SELECT 
	*, (rolling_people_vaccinated/population)*100 
FROM 
	#Percent_Population_Vaccinated



-- Creating Views to Store Data For Visualizations 

--Percent Population Vaccinated 

CREATE VIEW 
	PercentPopulationVaccinated AS 
SELECT 
	deaths.continent, 
	deaths.location,
	deaths.date,
	deaths.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY deaths.location 
		ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject..CovidDeaths deaths
	JOIN  PortfolioProject..CovidVaccinations vac
		ON deaths.location = vac.location 
		AND deaths.date = vac.date
WHERE 
	deaths.continent is not null 


CREATE VIEW 
	PercentPopulationVaccinated AS 
SELECT 
	deaths.continent, 
	deaths.location,
	deaths.date,
	deaths.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY deaths.location 
		ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject..CovidDeaths deaths
	JOIN  PortfolioProject..CovidVaccinations vac
		ON deaths.location = vac.location 
		AND deaths.date = vac.date
WHERE 
	deaths.continent is not null 