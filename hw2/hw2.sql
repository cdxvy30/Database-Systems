CREATE DATABASE nba2223season;
USE nba2223season;

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

-- create table
CREATE TABLE Teams (
  TeamName VARCHAR(50) PRIMARY KEY,
  City VARCHAR(50) NOT NULL,
  Division ENUM('East', 'West'),
  GroupName ENUM('Atlantic', 'Central', 'Southeast', 'Northwest', 'Pacific', 'Southwest'),
  Win INT NOT NULL DEFAULT 0,
  Lose INT NOT NULL DEFAULT 0,
  Standings INT NOT NULL,
  CHECK (Win + Lose <= 82),
  CHECK (Standings <= 15)
);

INSERT INTO Teams (TeamName, City, Division, GroupName, Win, Lose, Standings)
VALUES ('Celtics', 'Boston', 'East', 'Atlantic', 54, 24, 2);
INSERT INTO Teams (TeamName, City, Division, GroupName, Win, Lose, Standings)
VALUES ('Lakers', 'Los Angeles', 'West', 'Pacific', 40, 38, 7);
INSERT INTO Teams (TeamName, City, Division, GroupName, Win, Lose, Standings)
VALUES ('Warriors', 'Golden State', 'West', 'Pacific', 41, 38, 6);

-- create table
CREATE TABLE Players (
  PlyID VARCHAR(36) PRIMARY KEY,
  PlyName VARCHAR(50) NOT NULL,
  HeightFootInch VARCHAR(8) NOT NULL,
  WeightLbs INT NOT NULL,
  TeamName VARCHAR(30),
  BackNumber VARCHAR(3),
  Age INT NOT NULL,
  Experience INT NOT NULL,
  Country VARCHAR(50) NOT NULL,
  MentorID VARCHAR(36) DEFAULT NULL,
  FOREIGN KEY (TeamName) REFERENCES Teams(TeamName),
  FOREIGN KEY (MentorID) REFERENCES Players(PlyID),
  CHECK (Experience >= 0)
);

-- Create Disjoint Specialization
CREATE TABLE NormalContractPlayers (
  PlyID VARCHAR(36) PRIMARY KEY,
  ContractLen INT NOT NULL,
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID)
);

CREATE TABLE TwoWayContractPlayers (
  PlyID VARCHAR(36) PRIMARY KEY,
  GamePlayed INT DEFAULT 0,
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID),
  CHECK (GamePlayed <= 50)
);

-- Create Overlapping Specialization
CREATE TABLE PlayerPositions (
  PlyID VARCHAR(36),
  Position ENUM('Guard', 'Forward', 'Center') NOT NULL,
  PRIMARY KEY (PlyID, Position),
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID)
);

delimiter //
CREATE TRIGGER check_contract1
BEFORE INSERT ON TwoWayContractPlayers
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT PlyID FROM NormalContractPlayers WHERE PlyID = NEW.PlyID) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot insert row into TwoWayContractPlayers table. ID already exists in NormalContractPlayers table.';
  END IF;
END;//
delimiter ;

delimiter //
CREATE TRIGGER check_contract2
BEFORE INSERT ON NormalContractPlayers
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT PlyID FROM TwoWayContractPlayers WHERE PlyID = NEW.PlyID) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot insert row into NormalContractPlayers table. ID already exists in TwoWayContractPlayers table.';
  END IF;
END;//
delimiter ;

-- create union
CREATE TABLE Spokesman (
  SpokesmanID VARCHAR(36) PRIMARY KEY,
  SpokesFor VARCHAR(50) NOT NULL,
  SpokesmanType ENUM('Player', 'Team') NOT NULL,
  PlyID VARCHAR(36),
  TeamName VARCHAR(50),
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID),
  FOREIGN KEY (TeamName) REFERENCES Teams(TeamName)
);

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country)
VALUES (UUID(), 'Lebron James', '6-9', 250, 'Lakers', '6', 38, 19, 'USA');
INSERT INTO NormalContractPlayers (PlyID, ContractLen)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Lebron James'), 3);
-- Test
INSERT INTO TwoWayContractPlayers (PlyID, GamePlayed)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Lebron James'), 47);
--
INSERT INTO PlayerPositions (PlyID, Position)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Lebron James'), 'Forward');

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country)
VALUES (UUID(), 'Jayson Tatum', '6-8', 210, 'Celtics', '0', 25, 5, 'USA');
INSERT INTO NormalContractPlayers (PlyID, ContractLen)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Jayson Tatum'), 4);
INSERT INTO PlayerPositions (PlyID, Position)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Jayson Tatum'), 'Forward');
INSERT INTO PlayerPositions (PlyID, Position)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Jayson Tatum'), 'Guard');

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country)
VALUES (UUID(), 'Stephen Curry', '6-2', 185, 'Warriors', '30', 35, 13, 'USA');
INSERT INTO NormalContractPlayers (PlyID, ContractLen)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry'), 4);

-- This can work
CREATE TEMPORARY TABLE temp_players AS
SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry';

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country, MentorID)
VALUES (UUID(), 'Jordan Poole', '6-4', 194, 'Warriors', '3', 23, 3, 'USA', (SELECT PlyID FROM temp_players));

DROP TEMPORARY TABLE temp_players;
--

-- This cannot work
INSERT INTO Players
(PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country, MentorID)
VALUES
(UUID(), 'Jordan Poole', '6-4', 194, 'Warriors', '3', 23, 3, 'USA', (SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry'));
--

INSERT INTO NormalContractPlayers (PlyID, ContractLen)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Jordan Poole'), 3);

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country)
VALUES (UUID(), 'Anthony Lamb', '6-6', 227, 'Warriors', '40', 25, 2, 'USA');
INSERT INTO TwoWayContractPlayers (PlyID, GamePlayed)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Anthony Lamb'), 50);

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country)
VALUES (UUID(), 'Ty Jerome', '6-5', 195, 'Warriors', '10', 25, 3, 'USA');
INSERT INTO TwoWayContractPlayers (PlyID, GamePlayed)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Ty Jerome'), 50);

CREATE TEMPORARY TABLE temp_players AS
SELECT PlyID FROM Players WHERE PlyName = 'Lebron James';

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country, MentorID)
VALUES (UUID(), 'Alex Caruso', '6-5', 186, 'Lakers', '3', 27, 3, 'USA', (SELECT PlyID FROM temp_players));
INSERT INTO TwoWayContractPlayers (PlyID, GamePlayed)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Alex Caruso'), 50);

DROP TEMPORARY TABLE temp_players;

INSERT INTO Spokesman (SpokesmanID, SpokesFor, SpokesmanType, PlyID, TeamName)
VALUES (UUID(), 'Under Armour', 'Player', (SELECT PlyId FROM Players WHERE PlyName = 'Stephen Curry'), NULL);
INSERT INTO Spokesman (SpokesmanID, SpokesFor, SpokesmanType, PlyID, TeamName)
VALUES (UUID(), 'Nike', 'Player', (SELECT PlyId FROM Players WHERE PlyName = 'Lebron James'), NULL);
INSERT INTO Spokesman (SpokesmanID, SpokesFor, SpokesmanType, PlyID, TeamName)
VALUES (UUID(), 'Jordan', 'Player', (SELECT PlyId FROM Players WHERE PlyName = 'Jayson Tatum'), NULL);
INSERT INTO Spokesman (SpokesmanID, SpokesFor, SpokesmanType, PlyID, TeamName)
VALUES (UUID(), 'Adidas', 'Team', NULL, (SELECT TeamName FROM Teams WHERE TeamName = 'Warriors'));
-- Need to CHECK if match type and ID or not

-- create table
CREATE TABLE Managers (
  MngID VARCHAR(36) PRIMARY KEY,
  MngName VARCHAR(26) NOT NULL,
  Age INT NOT NULL,
  Experience INT NOT NULL,
  TeamName VARCHAR(50),
  FOREIGN KEY (TeamName) REFERENCES Teams(TeamName),
  CHECK (Age >= 0),
  CHECK (Experience >= 0)
);

INSERT INTO Managers
VALUES (UUID(), 'Bob Myers', 50, 12, 'Warriors');
INSERT INTO Managers
VALUES (UUID(), 'Brad Stevens', 50, 2, 'Celtics');
INSERT INTO Managers
VALUES (UUID(), 'Rod Pelinka', 50, 5, 'Lakers');

-- create table
CREATE TABLE Coaches (
  CchID VARCHAR(36) PRIMARY KEY,
  CchName VARCHAR(26) NOT NULL,
  Age INT NOT NULL,
  Experience INT NOT NULL,
  TeamName VARCHAR(50),
  FOREIGN KEY (TeamName) REFERENCES Teams(TeamName),
  CHECK (Age >= 0),
  CHECK (Experience >= 0)
);

INSERT INTO Coaches
VALUES (UUID(), 'Darwin Harm', 40, 1, 'Lakers');
INSERT INTO Coaches
VALUES (UUID(), 'Joseph Mazzulla', 40, 1, 'Celtics');
INSERT INTO Coaches
VALUES (UUID(), 'Steve Kerr', 40, 8, 'Warriors');

-- create table
CREATE TABLE Games (
  GameID VARCHAR(36) PRIMARY KEY,
  GameDate DATE NOT NULL,
  HomeTeam VARCHAR(50) NOT NULL,
  AwayTeam VARCHAR(50) NOT NULL,
  HomeScore INT NOT NULL,
  AwayScore INT NOT NULL,
  Winner VARCHAR(50) NOT NULL,
  CHECK (HomeScore >= 0),
  CHECK (AwayScore >= 0),
  CHECK (HomeScore != AwayScore)
);

INSERT INTO Games VALUES
(UUID(), '2022-10-19', 'Warriors', 'Lakers', 123, 109, 'Warriors');
INSERT INTO Games VALUES
(UUID(), '2023-02-12', 'Warriors', 'Lakers', 103, 109, 'Lakers');
INSERT INTO Games VALUES
(UUID(), '2023-02-24', 'Lakers', 'Warriors', 124, 111, 'Lakers');
INSERT INTO Games VALUES
(UUID(), '2023-03-06', 'Lakers', 'Warriors', 113, 105, 'Lakers');

-- Still try
delimiter //
CREATE TRIGGER insert_winner
AFTER INSERT ON Games
FOR EACH ROW
BEGIN
  IF NEW.HomeScore > NEW.AwayScore THEN
    UPDATE Games SET Winner = NEW.HomeTeam WHERE GameID = NEW.GameID;
  ELSE
    UPDATE Games SET Winner = NEW.AwayTeam WHERE GameID = NEW.GameID;
  END IF;
END;//
delimiter ;

-- create table (m-n)
CREATE TABLE Team_Play_Game (
  PlayID VARCHAR(36) PRIMARY KEY,
  TeamName VARCHAR(50) NOT NULL,
  GameID VARCHAR(36) NOT NULL,
  FOREIGN KEY (TeamName) REFERENCES Teams(TeamName),
  FOREIGN KEY (GameID) REFERENCES Games(GameID)
);

INSERT INTO Team_Play_Game
VALUES (UUID(), 'Warriors', (SELECT GameID FROM Games WHERE GameDate = '2022-10-19'));
INSERT INTO Team_Play_Game
VALUES (UUID(), 'Warriors', (SELECT GameID FROM Games WHERE GameDate = '2023-02-12'));
INSERT INTO Team_Play_Game
VALUES (UUID(), 'Warriors', (SELECT GameID FROM Games WHERE GameDate = '2023-02-24'));
INSERT INTO Team_Play_Game
VALUES (UUID(), 'Warriors', (SELECT GameID FROM Games WHERE GameDate = '2023-03-06'));
INSERT INTO Team_Play_Game
VALUES (UUID(), 'Lakers', (SELECT GameID FROM Games WHERE GameDate = '2022-10-19'));
INSERT INTO Team_Play_Game
VALUES (UUID(), 'Lakers', (SELECT GameID FROM Games WHERE GameDate = '2023-02-12'));
INSERT INTO Team_Play_Game
VALUES (UUID(), 'Lakers', (SELECT GameID FROM Games WHERE GameDate = '2023-02-24'));
INSERT INTO Team_Play_Game
VALUES (UUID(), 'Lakers', (SELECT GameID FROM Games WHERE GameDate = '2023-03-06'));

-- create table (m-n)
CREATE TABLE Player_Attend_Game (
  AtdID VARCHAR(36) PRIMARY KEY,
  PlyID VARCHAR(36) NOT NULL,
  GameID VARCHAR(36) NOT NULL,
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID),
  FOREIGN KEY (GameID) REFERENCES Games(GameID)
);

INSERT INTO Player_Attend_Game VALUES
(UUID(), (SELECT PlyID FROM Players WHERE PlyName = 'Lebron James'), (SELECT GameID FROM Games WHERE GameDate = '2022-10-19'));
INSERT INTO Player_Attend_Game VALUES
(UUID(), (SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry'), (SELECT GameID FROM Games WHERE GameDate = '2022-10-19'));
INSERT INTO Player_Attend_Game VALUES
(UUID(), (SELECT PlyID FROM Players WHERE PlyName = 'Jordan Poole'), (SELECT GameID FROM Games WHERE GameDate = '2022-10-19'));

-- create table (weak entity)
CREATE TABLE Injury (
  InjuryID INT NOT NULL AUTO_INCREMENT,
  InjType VARCHAR(50) NOT NULL,
  InjPosition VARCHAR(50) NOT NULL,
  InjStatus ENUM('Out', 'Doubtful', 'Questionable', 'Probable', 'Game time decision'),
  PRIMARY KEY (InjuryID, InjType)
);

INSERT INTO Injury (InjType, InjPosition, InjStatus)
VALUES ('Sprained', 'Right ankle', 'Out');
INSERT INTO Injury (InjType, InjPosition, InjStatus)
VALUES ('Sprained', 'Right Knee', 'Probable');
INSERT INTO Injury (InjType, InjPosition, InjStatus)
VALUES ('Strained', 'Left ankle', 'Probable');
INSERT INTO Injury (InjType, InjPosition, InjStatus)
VALUES ('Sore', 'Lower Back', 'Questionable');

CREATE TABLE InjuryReport (
  InjureID VARCHAR(36) PRIMARY KEY,
  InjuryID INT NOT NULL,
  PlyID VARCHAR(36) NOT NULL,
  FOREIGN KEY (InjuryID) REFERENCES Injury(InjuryID),
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID)
);

INSERT INTO InjuryReport (InjureID, InjuryID, PlyID)
VALUES (UUID(), (SELECT InjuryID FROM Injury WHERE InjuryID = 1), (SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry'));
INSERT INTO InjuryReport (InjureID, InjuryID, PlyID)
VALUES (UUID(), (SELECT InjuryID FROM Injury WHERE InjuryID = 2), (SELECT PlyID FROM Players WHERE PlyName = 'Jordan Poole'));
INSERT INTO InjuryReport (InjureID, InjuryID, PlyID)
VALUES (UUID(), (SELECT InjuryID FROM Injury WHERE InjuryID = 3), (SELECT PlyID FROM Players WHERE PlyName = 'Lebron James'));

-- create view
CREATE VIEW LakersMember AS
SELECT 'Player' AS MemberType, PlyID AS MemberID, PlyName AS MemberName
FROM Players
WHERE TeamName = 'Lakers'
UNION
SELECT 'Coach' AS MemberType, CchID AS MemberID, CchName AS MemberName
FROM Coaches
WHERE TeamName = 'Lakers';

CREATE VIEW WarriorsMember AS
SELECT 'Player' AS MemberType, PlyID AS MemberID, PlyName AS MemberName
FROM Players
WHERE TeamName = 'Warriors'
UNION
SELECT 'Coach' AS MemberType, CchID AS MemberID, CchName AS MemberName
FROM Coaches
WHERE TeamName = 'Warriors';

-- DROP DATABASE nba2223season;
