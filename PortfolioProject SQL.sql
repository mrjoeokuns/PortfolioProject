SELECT *
FROM CovidDeaths
WHERE continent IS NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--Select data we are going to be using

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM CovidDeaths
--ORDER BY 1,2

-- Looking at Total Cases vs Total Death
SELECT location, total_cases, total_deaths, (total_deaths/total_cases) * 100  PercentageDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what Percentage Population got Covid

SELECT location, continent , population ,MAX(total_cases) TotalCases, MAX((total_cases)/population) * 100  PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, continent, population
ORDER BY 5 DESC

--Looking at Countries with Higher infection rates compared to Population

SELECT location, continent ,MAX(total_cases) Totalcases, population, (MAX(total_cases)/population) * 100 InfectionRates
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, continent ,population
ORDER BY 5 DESC

--Showing Countries with highest death count 

SELECT location, continent , MAX(total_deaths) TotalDeathsCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY 3 DESC

--Breaking death count down by continent

SELECT location, MAX(total_deaths) TotalDeathsCount 
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

--Breakdown of Total Cases and Deaths Income Level

SELECT location IncomeLevel, MAX(Total_cases) TotalCases ,MAX(TOTAL_DEATHS) TotalDeaths
FROM CovidDeaths
WHERE location LIKE '%income%'
GROUP BY location
ORDER BY 2

-- Global Numbers

SELECT  SUM(new_cases) TotalNewCases, SUM(cast(new_deaths as FLOAT)) TotalNewDeaths , SUM(cast(new_deaths as FLOAT))/SUM(new_cases)  DeathPercentage
/*CASE
	WHEN SUM(new_deaths) = 0 THEN NULL
	ELSE SUM(new_deaths)/SUM(new_cases)* 100 
END AS DeathPercentage*/
FROM CovidDeaths
WHERE continent IS NOT NULL
--group BY date
ORDER BY 2 

-- Lookin at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations, Vac.new_vaccinations
, Sum(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.LOCATION, DEA.DATE) as RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

--Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, Sum(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.LOCATION, DEA.DATE) as RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

--Temp Table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated (
Continent nvarchar(225), 
Location nvarchar(225), 
Date datetime, 
Population float, 
New_Vaccinations float, 
RollingPeopleVaccinated float
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, Sum(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.LOCATION, DEA.DATE) as RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentagePopulationVaccinated

--
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, Sum(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.LOCATION, DEA.DATE) as RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentagePopulationVaccinated
ORDER BY 2,3