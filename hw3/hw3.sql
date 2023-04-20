/* create and use database */
CREATE DATABASE nbaSeason2223;
USE nbaSeason2223;

/* info */
CREATE TABLE self (
  StuID VARCHAR(10) NOT NULL,
  Department VARCHAR(10) NOT NULL,
  Degree ENUM('BSc', 'MSc', 'PhD') DEFAULT 'MSc',
  Grade int DEFAULT 1,
  Name VARCHAR(10) NOT NULL,
  PRIMARY KEY (StuID)
);

INSERT INTO self (StuID, Department, Name)
VALUES ('r11521603', '土木所電輔組', '陳冠錞');

/* table creation and insertion */

/*          Remember to create and insert here.          */

/* hw3 */

/* basic select 5% */
SELECT * FROM Players WHERE Age >=30 AND NOT (TeamName = 'Lakers' OR TeamName = 'Celtics');

/* basic projection 5% */
SELECT * FROM Players WHERE TeamName = 'Warriors';

/* basic rename 5% */
SELECT PlyName AS PlayerName, HeightFootInch AS Height, WeightLbs AS Weight
FROM Players;

/* union 5% */
SELECT PlyID AS ID, PlyName AS Name, Age, Experience
FROM Players
UNION
SELECT CchID AS ID, CchName AS Name, Age, Experience
FROM Coaches;

/* equijoin 10% */
SELECT P.PlyName, T.Win, T.Lose
FROM Players P
JOIN Teams T
ON P.TeamName = T.TeamName;

/* natural join 10% */
/* do not work */
SELECT MngName, CchName
FROM Managers
NATURAL JOIN Coaches;

/* theta join 10% */
SELECT P.PlyName, C.CchName
FROM Players P, Coaches C
WHERE C.TeamName = P.TeamName AND C.Experience > 9;

/* three table join 10% */
SELECT P.PlyName, P.BackNumber, P.Age, T.Win, T.Lose, C.CchName
FROM Players P
JOIN Teams T
ON P.TeamName = T.TeamName
JOIN Coaches C
ON T.TeamName = C.TeamName;

/* aggregate 5% */
SELECT TeamName, MAX(Age) AS Oldest, MIN(Age) AS Youngest, COUNT(BackNumber) AS NumberOfPlayers
FROM Players
GROUP BY TeamName;

/* aggregate 2 5% */
SELECT TeamName, AVG(Age) AS avg_age, SUM(Experience) AS total_exp
FROM Players,
GROUP BY TeamName
HAVING COUNT(BackNumber) > 3;

/* in 5% */
SELECT * FROM Players
WHERE TeamName IN ('Warriors', 'Lakers');

/* in 2 5% */
SELECT PlyName FROM Players
WHERE TeamName IN (SELECT TeamName FROM Teams);

/* correlated nested query 10% */
SELECT PlyName FROM Players
WHERE TeamName IN (SELECT TeamName FROM Teams);

/* correlated nested query 2 10% */
SELECT PlyName, BackNumber
FROM Players WHERE EXISTS (
  SELECT TeamName
  FROM Teams
  WHERE Teams.TeamName = Players.TeamName
  AND Win > 50
);
/* Below is not as expect. Still do not khow why. */
-- SELECT PlyName, BackNumber FROM Players WHERE EXISTS (SELECT TeamName FROM Teams WHERE Win > 50);

/* bonus 1 3% */
SELECT P.PlyName, C.CchName
FROM Players P
LEFT JOIN Coaches C
ON P.TeamName = C.TeamName;

/* bonus 2 2% */
SELECT PlyName, BackNumber
FROM Players WHERE NOT EXISTS (
  SELECT TeamName
  FROM Teams
  WHERE Teams.TeamName = Players.TeamName
  AND Win > 50
);


/* drop database */
DROP DATABASE nbaSeason2223;