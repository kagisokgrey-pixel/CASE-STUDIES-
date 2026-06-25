-- Databricks notebook source
--Getting an overview of the dataset --
SELECT *
FROM brighttv.default.userprofiles_bright_tv_dataset
LIMIT 10;

--Getting an Idea of how big the data is --
SELECT COUNT(*) AS NUM_OF_ROWS,
       COUNT(DISTINCT UserID) AS Cnt_user_id
FROM brighttv.default.userprofiles_bright_tv_dataset;

-- Checking for duplicates in my dataset--
SELECT UserID,COUNT(*) AS Duplicate_count
FROM brighttv.default.userprofiles_bright_tv_dataset
GROUP BY UserID
HAVING  COUNT(*) >1;

--Checking If there are null values in the userID
SELECT UserID
FROM brighttv.default.userprofiles_bright_tv_dataset
WHERE UserID IS NULL;
---------------------------------------------------------
--------------------Gender Checks------------------------
---------------------------------------------------------
SELECT DISTINCT gender
FROM brighttv.default.userprofiles_bright_tv_dataset;

SELECT COUNT(*) AS None_cnt
FROM brighttv.default.userprofiles_bright_tv_dataset
WHERE gender=' ';

SELECT COUNT(*) AS CNT,
       COUNT(DISTINCT UserID) AS Subs,
   CASE 
    WHEN gender=' '   THEN 'Unknown'
    WHEN gender ILIKE '%none%' THEN 'Unknown'
    ELSE gender 
    END AS Gender 
FROM brighttv.default.userprofiles_bright_tv_dataset
GROUP BY Gender;
---------------------------------------------------------
--------------------Race Checks------------------------
---------------------------------------------------------
SELECT DISTINCT Race
FROM brighttv.default.userprofiles_bright_tv_dataset;

SELECT COUNT(*) AS NumOfRowsInRaceIsNull
FROM brighttv.default.userprofiles_bright_tv_dataset
WHERE Race IS NULL;


SELECT DISTINCT 
  CASE 
    WHEN Race IN('other') THEN 'None'
    WHEN Race=' ' THEN 'None'
    ELSE Race 
    END AS race
FROM brighttv.default.userprofiles_bright_tv_dataset;

---------------------------------------------------------
--------------------Province Checks------------------------
---------------------------------------------------------

SELECT DISTINCT Province 
FROM brighttv.default.userprofiles_bright_tv_dataset;

SELECT DISTINCT 
   CASE 
     WHEN Province=' ' THEN 'Uncategorized'
     WHEN Province ILIKE '%none' THEN 'Uncategorized'
     ELSE Province
     END AS Region
FROM brighttv.default.userprofiles_bright_tv_dataset;

---------------------------------------------------------
--------------------Age Checks------------------------
---------------------------------------------------------

--Checking the Age range --
SELECT MIN(Age) AS Min_age,
       MAX(Age) AS Max_age
FROM brighttv.default.userprofiles_bright_tv_dataset;

--Checking if there's null values age column --
SELECT COUNT(*) AS CNT
FROM brighttv.default.userprofiles_bright_tv_dataset
WHERE Age IS NULL;

--Dividing the users into age groups --

WITH User_Profiles AS (
SELECT UserID,
     CASE 
     WHEN Province=' ' THEN 'Uncategorized'
     WHEN Province ILIKE '%none' THEN 'Uncategorized'
     ELSE Province
     END AS Region,
    Age,
    CASE
     WHEN Age= 0 THEN 'Babies'
     WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
     WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
     WHEN Age BETWEEN 20 AND 35 THEN 'Young Adult'
     WHEN Age BETWEEN 36 AND 50 THEN 'Mature Adult'
     WHEN Age BETWEEN 51 AND 65 THEN 'Elder'
     WHEN Age >65 THEN 'Seniours'
     END AS AGE_GROUP,

  CASE 
   WHEN (EMAIL IS NOT NULL) OR (Email <>' ') OR (Email NOT IN ('None')) THEN 1 
    ELSE 0
    END AS Email_flag,
  
  CASE 
    WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle`<>' ') OR (`Social Media Handle` NOT IN ('None')) THEN 1 
    ELSE 0 
    END AS SocialMedia_flag,

  CASE 
    WHEN Race IN('other') THEN 'None'
    WHEN Race=' ' THEN 'None'
    ELSE Race 
    END AS race,

  CASE 
    WHEN gender=' '   THEN 'Unknown'
    WHEN gender ILIKE '%none%' THEN 'Unknown'
    ELSE gender 
    END AS Gender
FROM brighttv.default.userprofiles_bright_tv_dataset
),
Viewrship_ AS(
  SELECT 
          COALESCE(UserID0,userid4,0) AS UserID,
          TO_CHAR(RecordDate2,'yyyyMM') AS month_id,
          TO_DATE(RecordDate2) AS Watch_date,
         -- TIME(RecordDate2) Watch_rime,
          DAYOFWEEK(RecordDate2) AS Day_of_week,
          DAYNAME(RecordDate2) AS Day_name,
    CASE 
       WHEN Day_name IN('Sat','Sun') THEN 'Weekend'
       ELSE 'Weekday'
       END AS Day_Classification, 
          MONTHNAME(RecordDate2) AS Month_name,
 
CASE 
    WHEN Channel2 IN('Sawsee','Sawsee') THEN 'SawSee'
    WHEN Channel2 IN('SuperSport Live Events','Live on SuperSport','SuperSport Live Events','DStv Events 1')
     THEN 'Live Events'
     ELSE Channel2
     END AS TV_Channel ,
    date_format(RecordDate2,'HH:mm:ss') AS Watch_Time,
    HOUR(RecordDate2) AS hour_of_day,
  CASE 
  WHEN Watch_Time BETWEEN '00:00:00' AND '05:59:59' THEN 'Mid-Night'
  WHEN Watch_Time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
  WHEN Watch_Time BETWEEN '12:00:00' AND '16:59:59' THEN 'After-Noon'
  WHEN Watch_Time BETWEEN '17:00:00' AND '23:59:59' THEN 'Evening'
  END AS Time_of_Day,
    date_format(`Duration 2`,'HH:mm:ss') AS Duration,
  CASE 
  WHEN Duration BETWEEN '00:00:00' AND '00:30:00' THEN 'Low Usage'
  WHEN Duration BETWEEN '00:30:01' AND '00:59:59' THEN 'Medium Usage'
  WHEN Duration > '00:59:59' THEN 'High Usage'
  END AS Screen_Time 
FROM brighttv.default.viewrship_dataset 
)
SELECT A.*,
      B.Region,
      B.Age,
      B.AGE_GROUP,
      B.Email_flag,
      B.SocialMedia_flag,
      B.race,
      B.Gender
FROM Viewrship_ AS A 
LEFT JOIN User_Profiles AS B
ON A.UserID = B.UserID;

