--How many olympics games have been held so far
select count(distinct Games)
from olympics.dbo.athlete_events

--list down all Olympics game held so far
select distinct Games, City
from olympics.dbo.athlete_events

--total no of nations who participated in each olympic game
select distinct Games, count(distinct NOC) as total_countries
from  olympics.dbo.athlete_events
group by Games
--which year saw the highest and lowest no of countries participating in olympics 
SELECT Year, total_countries
FROM (
    SELECT TOP 1 Year, COUNT(DISTINCT NOC) AS total_countries
    FROM olympics.dbo.athlete_events
    GROUP BY Year
    ORDER BY total_countries DESC
) AS highest_countries

UNION ALL

SELECT Year, total_countries
FROM (
    SELECT TOP 1 Year, COUNT(DISTINCT NOC) AS total_countries
    FROM olympics.dbo.athlete_events
    GROUP BY Year
    ORDER BY total_countries ASC
) AS lowest_countries;

--which nation has participated in all of the olympic games
--since we know the total number of games,we need to see what has the same number

SELECT olympics.dbo.noc_regions.region, COUNT(DISTINCT olympics.dbo.athlete_events.Games) AS Total_participated_games
FROM olympics.dbo.athlete_events
JOIN olympics.dbo.noc_regions ON olympics.dbo.athlete_events.NOC = olympics.dbo.noc_regions.NOC
GROUP BY olympics.dbo.noc_regions.region
HAVING COUNT(DISTINCT olympics.dbo.athlete_events.Games) = 51;

--The sport that was played in all summer olympics
-- Step 2 is to find the number of summer games 
WITH t1 AS (
    SELECT COUNT(DISTINCT Games) AS total_games
    FROM olympics.dbo.athlete_events
    WHERE Season = 'Summer'
),
t2 AS (
    SELECT DISTINCT Games, Sport
    FROM olympics.dbo.athlete_events
    WHERE Season = 'Summer'
),
t3 AS (
    SELECT sport, COUNT(1) AS no_of_games
    FROM t2
    GROUP BY sport
)

SELECT *
FROM t3
JOIN t1 ON t1.total_games = t3.no_of_games;

--sport that was played only once in the olympics

select sport, count(distinct Games) as no_of_games
from olympics.dbo.athlete_events
group by sport
having count(distinct Games)  = 1


--total number of sport played in each olympic games

select Games, count(distinct sport) as number_of_sports
from olympics.dbo.athlete_events
group by Games

--Oldest athlete to win a gold medal
select top 1 Name, sex, Age
from olympics.dbo.athlete_events
where Medal = 'Gold'
order by Age desc

--top 5 athletes who have won the most gold medals
select top 5 name, count(Medal)
from olympics.dbo.athlete_events
where Medal = 'Gold'
group by name
order by count(Medal) desc

--list down total gold, silver and bronze medals won by each country
;WITH t1 AS (
    SELECT Team, COUNT(Medal) AS gold_count
    FROM olympics.dbo.athlete_events
    WHERE Medal = 'Gold'
    GROUP BY Team
),
t2 AS (
    SELECT Team, COUNT(Medal) AS bronze_count
    FROM olympics.dbo.athlete_events
    WHERE Medal = 'Bronze'
    GROUP BY Team
),
t3 AS (
    SELECT Team, COUNT(Medal) AS silver_count
    FROM olympics.dbo.athlete_events
    WHERE Medal = 'Silver'
    GROUP BY Team
)
SELECT t1.Team, t1.gold_count, t2.bronze_count, t3.silver_count
FROM t1
JOIN t2 ON t1.Team = t2.Team
JOIN t3 ON t1.Team = t3.Team;
--Percentage increase in female athletes.
SELECT
    SUM(CASE WHEN Year = 2000 AND Sex = 'F' THEN 1 ELSE 0 END) AS FemaleCount2000,
    SUM(CASE WHEN Year = 2016 AND Sex = 'F' THEN 1 ELSE 0 END) AS FemaleCount2016,
    ROUND(((SUM(CASE WHEN Year = 2016 AND Sex = 'F' THEN 1 ELSE 0 END) - SUM(CASE WHEN Year = 2000 AND Sex = 'F' THEN 1 ELSE 0 END)) * 100.0 / SUM(CASE WHEN Year = 2000 AND Sex = 'F' THEN 1 ELSE 0 END)), 2) AS PercentageIncrease
FROM
    olympics.dbo.athlete_events;
