
--Selecting all the data

select * from [Portfolio-Projects]..CovidDeaths
order by 3,4

select * from [Portfolio-Projects]..CovidVaccinations
order by 3,4



--Death analysis
--Selecting the necessary data

select location, date, population, total_cases, new_cases, total_deaths
from [Portfolio-Projects]..CovidDeaths
--where location = 'India'
order by 1,2



--Total cases vs Total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Portfolio-Projects]..CovidDeaths
--where location = 'India'
order by 1,2



--Population vs Total cases

select location, date, population, total_cases, (total_cases/population)*100 as case_percentage
from [Portfolio-Projects]..CovidDeaths
--where location = 'India'
order by 1,2



--Maximum cases and deaths as compared to population

select location, population, max(total_cases) as max_cases, max(cast(total_deaths as int)) as max_deaths
from [Portfolio-Projects]..CovidDeaths
--where location = 'India'
group by location, population
--order by max_cases desc
order by max_deaths desc



--As the location column contains World and continent's names, so considering the locations where continent is not null

select * from [Portfolio-Projects]..CovidDeaths
--where continent is null
where continent is not null
order by 3,4



--Highest infection rate as compared to population

select location, population, max(total_cases) as max_cases, max((total_cases/population)*100) as percent_maxcases
from [Portfolio-Projects]..CovidDeaths
--where location = 'India'
where continent is not null
group by location, population
--order by max_cases desc
order by percent_maxcases desc



--Highest death rate as compared to population

select location, population, max(cast(total_deaths as int)) as max_deaths, max((total_deaths/population)*100) as percent_maxdeaths
from [Portfolio-Projects]..CovidDeaths
--where location = 'India'
where continent is not null
group by location, population
--order by max_deaths desc
order by percent_maxdeaths desc



--Total cases and deaths across continents and around the world

select location, population, max(total_cases) as continents_cases, max(cast(total_deaths as int)) as continents_deaths
from [Portfolio-Projects]..CovidDeaths
where continent is null
group by location, population
--order by continents_cases desc
order by continents_deaths desc



--Global cases and deaths on daily basis

select date, sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as global_death_percentage
from [Portfolio-Projects]..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as global_death_percentage
from [Portfolio-Projects]..CovidDeaths
where continent is not null





--Vaccination analysis
--Joining both tables

select * from [Portfolio-Projects]..CovidDeaths deaths
join [Portfolio-Projects]..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date



--Vaccination on daily basis

select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
from [Portfolio-Projects]..CovidDeaths deaths
join [Portfolio-Projects]..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
where deaths.continent is not null
order by 2,3



--Population vs Vaccinations

select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_vaccinations
from [Portfolio-Projects]..CovidDeaths deaths
join [Portfolio-Projects]..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
--where deaths.location = 'India'
where deaths.continent is not null
order by 2,3



--Vaccination percentage using CTE

with vaccination_percentage (continent, location, date, population, new_vaccinations, rolling_vaccinations) as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_vaccinations
from [Portfolio-Projects]..CovidDeaths deaths
join [Portfolio-Projects]..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
--where deaths.location = 'India'
where deaths.continent is not null
--order by 2,3
)
select *, (rolling_vaccinations/population)*100 as percent_vaccinations
from vaccination_percentage



--Creating view to store data for visualization

create view vaccination_percentage as
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_vaccinations
from [Portfolio-Projects]..CovidDeaths deaths
join [Portfolio-Projects]..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
--where deaths.location = 'India'
where deaths.continent is not null
--order by 2,3

select * from vaccination_percentage
