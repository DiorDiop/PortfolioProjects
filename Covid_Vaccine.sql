SELECT *
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..Covid_Vaccinations
WHERE continent is not null
ORDER BY 3,4

--Select the data that we are going to use

SELECT location, date, total_cases, new_cases, population
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE location LIKE '%Canada%'
and WHERE continent is not null
ORDER BY location, date


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (CAST(total_deaths AS float) / CAST(population AS float)) * 100 AS InfectionPercentage
FROM PortfolioProject..Covid_Deaths
WHERE location LIKE '%Canada%'
and WHERE continent is not null
ORDER BY location, date

--Looking at countries with Highest Infection Rate compare to Population

SELECT location, population, MAX(CAST(total_cases AS float)) AS HighestInfection, MAX(CAST(total_deaths AS float) / CAST(population AS float)) * 100 AS InfectionPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
--WHERE location LIKE '%Canada%'
GROUP BY location, population
ORDER BY InfectionPercentage DESC

--Countries with Highest Death Count

SELECT location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
--WHERE location LIKE '%Canada%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continent with Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
--WHERE location LIKE '%Canada%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(CAST(new_cases AS float)) AS Total_Cases, SUM(CAST(new_deaths AS float)) AS Total_Deaths, (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float))) * 100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE '%Canada%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccination

WITH PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated) AS
(
    SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
        SUM(CAST(cv.new_vaccinations AS float))
        OVER (PARTITION BY cd.location ORDER BY cd.date)
        AS PeopleVaccinated
    FROM PortfolioProject..Covid_Deaths cd
    JOIN PortfolioProject..Covid_Vaccinations cv
        ON cd.location = cv.location
        AND cd.date = cv.date
    WHERE cd.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *, ((CAST(PeopleVaccinated AS float)) / (CAST(population AS float))) * 100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_Vaccination NUMERIC,
	PeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS float))
    OVER (PARTITION BY cd.location ORDER BY cd.date)
    AS PeopleVaccinated
FROM PortfolioProject..Covid_Deaths cd
JOIN PortfolioProject..Covid_Vaccinations cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ((CAST(PeopleVaccinated AS float)) / (CAST(population AS float))) * 100
FROM #PercentPopulationVaccinated



--View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated1 AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS float))
    OVER (PARTITION BY cd.location ORDER BY cd.date)
    AS PeopleVaccinated
FROM PortfolioProject..Covid_Deaths cd
JOIN PortfolioProject..Covid_Vaccinations cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3