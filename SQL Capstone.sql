-- Databricks notebook source
--First, I need to examine the tables I created.

-- COMMAND ----------

SELECT * FROM athlete_events

-- COMMAND ----------

SELECT * FROM noc_regions

-- COMMAND ----------

--Counting the number of IDs in the athlete_events table to get total rows. Then doing the same for the noc_regions table.

-- COMMAND ----------

SELECT COUNT(ID) AS athletes
FROM athlete_events


-- COMMAND ----------

SELECT COUNT(NOC)
FROM noc_regions

-- COMMAND ----------

--I can see by looking at the tables themselves there are duplicated IDs, so I need to create a new table isolating them.

-- COMMAND ----------

CREATE TABLE IF NOT EXISTS unique_athletes AS
SELECT DISTINCT ID,
Name,
Sex,
AGE,
Height,
Weight,
Team,
NOC,
Games,
Year,
Season,
City,
Sport,
Event,
Medal
FROM athlete_events

-- COMMAND ----------

--I'm interested in finding out if the countries that field the most athletes win the most medals. Secondarily, I will be checking the age/medal ratio. I considered checking gender differences, but as there are literally mens and womens events and the same number of medals are awarded for each, you and I both concluded that would be a waste of time.

--As part of my initial analysis, I'm counting the number of athletes per region, so I join the tables together to get the numbers.

-- COMMAND ----------

SELECT COUNT(ID) AS athletes,
      N.region
FROM athlete_events AS A
JOIN
  noc_regions AS N
ON A.NOC = N.NOC
GROUP BY region
ORDER BY athletes DESC

-- COMMAND ----------

--Run the same command again on the distinct table to check difference.

-- COMMAND ----------

SELECT COUNT(ID) AS athletes,
      N.region
FROM unique_athletes AS A
JOIN
  noc_regions AS N
ON A.NOC = N.NOC
GROUP BY region
ORDER BY athletes DESC

-- COMMAND ----------

-- Overall the change seems to be in the 1-2% range. For my purposes, I don't think I'll need to account for that in my analyses.

--Now I'll count the number of medals won per region.

-- COMMAND ----------

SELECT COUNT(ID) AS medals,
      N.region,
      A.medal
FROM athlete_events AS A
JOIN
  noc_regions AS N
ON A.NOC = N.NOC
WHERE medal NOT IN ("NA")
GROUP BY N.region, A.medal
ORDER BY medals DESC

-- COMMAND ----------

--I had meant to count the total number of medals, not the total by type. Re-run the command again without the "medal" column.

-- COMMAND ----------

SELECT DISTINCT (N.region),
  COUNT(medal) AS medals
FROM noc_regions AS N
JOIN
  athlete_events AS A
ON A.NOC = N.NOC
WHERE medal NOT IN ("NA")
GROUP BY N.region
ORDER BY medals DESC

-- COMMAND ----------

--Now I want to get a rough idea of the number of medals won by age and the associated event.

-- COMMAND ----------

SELECT DISTINCT A.ID,
  A.name,
  N.region,
  A.age,
  A.sport,
  COUNT(A.medal) AS medals
FROM athlete_events AS A
JOIN
  noc_regions AS N
ON A.NOC = N.NOC
WHERE medal NOT IN ("NA")
GROUP BY A.ID, A.name, A.age, A.sport, N.region
ORDER BY medals DESC

-- COMMAND ----------

--It does indeed seem to be that age is an important factor, with teenagers medaling in gymnastics, swimming, and diving, and people in their early to mid-20's medaling much more often. It also becomes apparent that for many years, age, height, and weight were merely optional metrics to obtain. It says a lot about society that we started focusing on that instead of what these amazing athletes can do, doesn't it?

--As I was scrolling through the entries, most of the events for the younger crowd seemed to involve less 'power' and more 'power-weight' ratio, whereas the older crowd seems to favor shooting, archery, and equestrianism, which involves experience, dexterity, and in the case of equestrianism, a bond built with the animal. There's also Art Competitions, which was poetry. They apparently got rid of it due to the dubious quality of the poetry produced.

--Anyway, there are a few outliers in the events themselves. For instance, there's a 16-year old weightlifter who participated in the 2008 Olympics who is (and maybe I'mm assuming too much here) not going to have the same body type as a 16-year old gymnast. For that reason trying to get the average height or weight of an olympic medalist would draw, at best, spurious correlations. Anyone who saw Michael Phelps and Simone Biles in the same room and tried to "average" them for a talented olympic athlete would sin against God and humanity and miss the larger picture.

--My goal now is the find the average age of a medalist, then the average of a medalist per region. I'm sure there are more analyses I could run, but I'm almost at the end of my free period on Coursera and I don't want to spend $40 if I don't have to.

-- COMMAND ----------

SELECT medal,
AVG(age) AS average,
MIN(age) AS min,
MAX(age) AS max,
COUNT(medal) AS medals
FROM athlete_events
WHERE medal NOT IN ("NA")
GROUP BY medal
ORDER BY medals DESC

-- COMMAND ----------

--I am thoroughly unsurprised. But go 10-year old kid! Dimitrios Loundras won a bronze medal in Gymnastics in 1896. They changed the age requirements in 1997, presumably to stop 111-year old Greek men from dominating the sport. Now the average age per region and getting rid of the minimum and maximum to aid visualization.

-- COMMAND ----------

SELECT A.medal,
A.age,
COUNT(A.medal) AS medals,
N.region
FROM athlete_events AS A
JOIN
  noc_regions AS N
ON A.NOC = N.NOC
WHERE medal NOT IN ("NA")
GROUP BY N.region, A.medal, A.age
ORDER BY medals DESC

-- COMMAND ----------

--And that's it! The average number of medals won seems to hold pretty steady at 25 per the previous calculation. However, checking the countries with the most medals, those that win the most medals also have higher average ages. They're able to field more athletes total, including events where the average age is higher, without compromising quality in other events. The average age of a medal winner hides the advanced age of other high performing olympians.

--Of course, this is my first attempt and my math could be totally off, but that's why we're all here to help each other, right?
