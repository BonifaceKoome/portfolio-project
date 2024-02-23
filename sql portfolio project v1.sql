--select *
--from sqlportfolioprojects..CovidVaccinations$
--order by 3,4
select *
from sqlportfolioprojects..CovidDeaths$
order by 1,2


--looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathpercentage
from sqlportfolioprojects..CovidDeaths$
where location like '%kenya%'
order by 1,2

--looking at total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 AS rateofinfection
from sqlportfolioprojects..CovidDeaths$
where location like '%kenya%'
order by 1,2

--looking at countries with the highest infectionrate ompareed to population
select location,MAX(total_cases) AS HighestinfectionNO ,population,MAX((total_cases/population))*100 AS rateofinfection
from sqlportfolioprojects..CovidDeaths$
GROUP BY location,population
order by rateofinfection

--Countries with the highest deathcount
select location,MAX(cast(total_deaths as int)) As highestdeathcount 
from sqlportfolioprojects..CovidDeaths$
where continent is not NULL
GROUP BY location,population
order by highestdeathcount DESC

--BREAKING IT DOWN BY CONTINENTS
select continent,MAX(cast(total_deaths as int)) As highestdeathcount 
from sqlportfolioprojects..CovidDeaths$
where continent is not NULL
GROUP BY continent
order by highestdeathcount DESC

--Global numbers
select sum(new_cases) as total_cases ,sum(cast(new_deaths as int))as total_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from sqlportfolioprojects..CovidDeaths$
--where location like '%kenya%'
where continent is not  NULL
order by 1,2

--look at the total population vs people vaccinated
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location
order by dea.location,dea.date)as rollingvaccount
from sqlportfolioprojects..CovidDeaths$ dea
join sqlportfolioprojects..CovidVaccinations$ vac
   ON dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not  NULL
order by 2,3
 
 with popvsvac (continent,location,date,population,new_vaccinations,rollingvaccount)
 as
 (
 select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location
order by dea.location,dea.date)as rollingvaccount
from sqlportfolioprojects..CovidDeaths$ dea
join sqlportfolioprojects..CovidVaccinations$ vac
   ON dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not  NULL
)
select *,(rollingvaccount/population)*100
from popvsvac

--temp table
DROP TABLE IF exists #perpopulationvaccinated
 CREATE TABLE #perpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingvaccount numeric,
 )

insert into #perpopulationvaccinated
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location
order by dea.location,dea.date)as rollingvaccount
from sqlportfolioprojects..CovidDeaths$ dea
join sqlportfolioprojects..CovidVaccinations$ vac
   ON dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not  NULL

select *,(rollingvaccount/population)*100
from #perpopulationvaccinated
 
 --creating views to store data forlater visualizations
 create view perpopulationvaccinated as
 select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location
order by dea.location,dea.date)as rollingvaccount
from sqlportfolioprojects..CovidDeaths$ dea
join sqlportfolioprojects..CovidVaccinations$ vac
   ON dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not  NULL
--order by 2,3

select *
from perpopulationvaccinated