/* create and use database */
CREATE DATABASE nba2223season;
USE nba2223season;

/* info */
CREATE TABLE self (
  StuID VARCHAR(10) NOT NULL,
  Department VARCHAR(10) NOT NULL,
  Degree ENUM('BSc', 'MSc', 'PhD') DEFAULT 'MSc',
  Grade int DEFAULT 1,
  Name VARCHAR(10) NOT NULL,
  PRIMARY KEY (StuID)
);

/* create table */
CREATE TABLE Teams (
  TeamName VARCHAR(30) PRIMARY KEY,
  City VARCHAR(50) NOT NULL,
  Division ENUM('East', 'West'),
  GroupName ENUM('Atlantic', 'Central', 'Southeast', 'Northwest', 'Pacific', 'Southwest'),
  Win INT NOT NULL DEFAULT 0,
  Lose INT NOT NULL DEFAULT 0,
  Standings INT NOT NULL,
  CHECK (Win + Lose <= 82),
  CHECK (Standings <= 15)
);

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

CREATE TABLE Spokesman (
  SpokesmanID VARCHAR(36) PRIMARY KEY,
  SpokesFor VARCHAR(50) NOT NULL,
  SpokesmanType ENUM('Player', 'Team') NOT NULL,
  PlyID VARCHAR(36),
  TeamName VARCHAR(50),
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID),
  FOREIGN KEY (TeamName) REFERENCES Teams(TeamName)
);

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

CREATE TABLE Coaches (
  CchID VARCHAR(36) PRIMARY KEY,
  CchName VARCHAR(26) NOT NULL,
  Age INT NOT NULL,
  Experience INT NOT NULL,
  TeamName VARCHAR(30),
  FOREIGN KEY (TeamName) REFERENCES Teams(TeamName),
  CHECK (Age >= 0),
  CHECK (Experience >= 0)
);

CREATE TABLE Tactics (
  TacticID INT NOT NULL AUTO_INCREMENT,
  TacticName VARCHAR(30) NOT NULL,
  PRIMARY KEY (TacticID)
);

CREATE TABLE Strategy (
  StrategyID INT NOT NULL AUTO_INCREMENT,
  StrategyName VARCHAR(30) NOT NULL,
  PRIMARY KEY (StrategyID)
);

CREATE TABLE Shooting (
  ShootingID INT NOT NULL AUTO_INCREMENT,
  Motion ENUM('One-motion', 'One point five motion', 'Two-motion') NOT NULL,
  PRIMARY KEY (ShootingID)
);


CREATE TABLE OffenseCoach (
  CchID VARCHAR(36),
  TacticID INT,
  FOREIGN KEY (CchID) REFERENCES Coaches(CchID),
  FOREIGN KEY (TacticID) REFERENCES Tactics(TacticID),
  PRIMARY KEY (CchID, TacticID)
);

CREATE TABLE DefenseCoach (
  CchID VARCHAR(36),
  StrategyID INT,
  FOREIGN KEY (CchID) REFERENCES Coaches(CchID),
  FOREIGN KEY (StrategyID) REFERENCES Strategy(StrategyID),
  PRIMARY KEY (CchID, StrategyID)
);

CREATE TABLE ShootingCoach (
  CchID VARCHAR(36),
  ShootingID INT,
  FOREIGN KEY (CchID) REFERENCES Coaches(CchID),
  FOREIGN KEY (ShootingID) REFERENCES Shooting(ShootingID),
  PRIMARY KEY (CchID, ShootingID)
);

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

CREATE TABLE Team_Play_Game (
  PlayID VARCHAR(36) PRIMARY KEY,
  TeamName VARCHAR(50) NOT NULL,
  GameID VARCHAR(36) NOT NULL,
  FOREIGN KEY (TeamName) REFERENCES Teams(TeamName),
  FOREIGN KEY (GameID) REFERENCES Games(GameID)
);

CREATE TABLE Player_Attend_Game (
  AtdID VARCHAR(36) PRIMARY KEY,
  PlyID VARCHAR(36) NOT NULL,
  GameID VARCHAR(36) NOT NULL,
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID),
  FOREIGN KEY (GameID) REFERENCES Games(GameID)
);

CREATE TABLE Injury (
  InjuryID INT NOT NULL AUTO_INCREMENT,
  InjType VARCHAR(50) NOT NULL,
  InjPosition VARCHAR(50) NOT NULL,
  InjStatus ENUM('Out', 'Doubtful', 'Questionable', 'Probable', 'Game time decision'),
  PRIMARY KEY (InjuryID, InjType)
);

CREATE TABLE InjuryReport (
  InjureID VARCHAR(36) PRIMARY KEY,
  InjuryID INT NOT NULL,
  PlyID VARCHAR(36) NOT NULL,
  FOREIGN KEY (InjuryID) REFERENCES Injury(InjuryID),
  FOREIGN KEY (PlyID) REFERENCES Players(PlyID)
);

/* create trigger to make sure disjoint specialization and derived attribute */
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

delimiter //
CREATE TRIGGER insert_winner
BEFORE INSERT ON Games
FOR EACH ROW
BEGIN
  IF NEW.HomeScore > NEW.AwayScore THEN
    SET NEW.Winner = NEW.HomeTeam;
  ELSE
    SET NEW.Winner = NEW.AwayTeam;
  END IF;
END;//
delimiter ;


/* insert */
INSERT INTO self (StuID, Department, Name)
VALUES ('r11521603', '土木所電輔組', '陳冠錞');

INSERT INTO Teams (TeamName, City, Division, GroupName, Win, Lose, Standings)
VALUES ('Celtics', 'Boston', 'East', 'Atlantic', 54, 24, 2);
INSERT INTO Teams (TeamName, City, Division, GroupName, Win, Lose, Standings)
VALUES ('Lakers', 'Los Angeles', 'West', 'Pacific', 40, 38, 7);
INSERT INTO Teams (TeamName, City, Division, GroupName, Win, Lose, Standings)
VALUES ('Warriors', 'Golden State', 'West', 'Pacific', 41, 38, 6);

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country)
VALUES (UUID(), 'Lebron James', '6-9', 250, 'Lakers', '6', 38, 19, 'USA');
INSERT INTO NormalContractPlayers (PlyID, ContractLen)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Lebron James'), 3);

INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country)
VALUES (UUID(), 'Jayson Tatum', '6-8', 210, 'Celtics', '0', 25, 5, 'USA');
INSERT INTO NormalContractPlayers (PlyID, ContractLen)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Jayson Tatum'), 4);


INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country)
VALUES (UUID(), 'Stephen Curry', '6-2', 185, 'Warriors', '30', 35, 13, 'USA');
INSERT INTO NormalContractPlayers (PlyID, ContractLen)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry'), 4);

CREATE TEMPORARY TABLE temp_players AS
SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry';
INSERT INTO Players (PlyID, PlyName, HeightFootInch, WeightLbs, TeamName, BackNumber, Age, Experience, Country, MentorID)
VALUES (UUID(), 'Jordan Poole', '6-4', 194, 'Warriors', '3', 23, 3, 'USA', (SELECT PlyID FROM temp_players));
DROP TEMPORARY TABLE temp_players;
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
DROP TEMPORARY TABLE temp_players;
INSERT INTO TwoWayContractPlayers (PlyID, GamePlayed)
VALUES ((SELECT PlyID FROM Players WHERE PlyName = 'Alex Caruso'), 50);

INSERT INTO Spokesman (SpokesmanID, SpokesFor, SpokesmanType, PlyID, TeamName)
VALUES (UUID(), 'Under Armour', 'Player', (SELECT PlyId FROM Players WHERE PlyName = 'Stephen Curry'), NULL);
INSERT INTO Spokesman (SpokesmanID, SpokesFor, SpokesmanType, PlyID, TeamName)
VALUES (UUID(), 'Nike', 'Player', (SELECT PlyId FROM Players WHERE PlyName = 'Lebron James'), NULL);
INSERT INTO Spokesman (SpokesmanID, SpokesFor, SpokesmanType, PlyID, TeamName)
VALUES (UUID(), 'Jordan', 'Player', (SELECT PlyId FROM Players WHERE PlyName = 'Jayson Tatum'), NULL);
INSERT INTO Spokesman (SpokesmanID, SpokesFor, SpokesmanType, PlyID, TeamName)
VALUES (UUID(), 'Adidas', 'Team', NULL, (SELECT TeamName FROM Teams WHERE TeamName = 'Warriors'));

INSERT INTO Managers VALUES (UUID(), 'Bob Myers', 50, 12, 'Warriors');
INSERT INTO Managers VALUES (UUID(), 'Brad Stevens', 50, 2, 'Celtics');
INSERT INTO Managers VALUES (UUID(), 'Rod Pelinka', 50, 5, 'Lakers');

INSERT INTO Coaches VALUES (UUID(), 'Darwin Harm', 40, 1, 'Lakers');
INSERT INTO Coaches VALUES (UUID(), 'Joseph Mazzulla', 40, 1, 'Celtics');
INSERT INTO Coaches VALUES (UUID(), 'Steve Kerr', 40, 8, 'Warriors');
INSERT INTO Coaches VALUES (UUID(), 'Mike Brown', 40, 10, 'Warriors');

INSERT INTO Tactics (TacticName) VALUES ('Spain Pick & Roll');
INSERT INTO Tactics (TacticName) VALUES ('Pick & Roll');
INSERT INTO Tactics (TacticName) VALUES ('5-out');
INSERT INTO Tactics (TacticName) VALUES ('Run & Gun');
INSERT INTO Strategy (StrategyName) VALUES ('ICE');
INSERT INTO Strategy (StrategyName) VALUES ('Double Team');
INSERT INTO Strategy (StrategyName) VALUES ('Baseline Trap');
INSERT INTO Strategy (StrategyName) VALUES ('2-3 Zone');
INSERT INTO Strategy (StrategyName) VALUES ('3-2 Zone');
INSERT INTO Strategy (StrategyName) VALUES ('1-3-1 Zone');
INSERT INTO Shooting (Motion) VALUES ('One-motion');
INSERT INTO Shooting (Motion) VALUES ('One point five motion');
INSERT INTO Shooting (Motion) VALUES ('Two-motion');

INSERT INTO OffenseCoach (CchID, TacticID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Steve Kerr'), (SELECT TacticID FROM Tactics WHERE TacticID = 1));
INSERT INTO OffenseCoach (CchID, TacticID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Steve Kerr'), (SELECT TacticID FROM Tactics WHERE TacticID = 3));
INSERT INTO OffenseCoach (CchID, TacticID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Darwin Harm'), (SELECT TacticID FROM Tactics WHERE TacticID = 2));
INSERT INTO DefenseCoach (CchID, StrategyID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Mike Brown'), (SELECT StrategyID FROM Strategy WHERE StrategyID = 1));
INSERT INTO DefenseCoach (CchID, StrategyID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Mike Brown'), (SELECT StrategyID FROM Strategy WHERE StrategyID = 2));
INSERT INTO DefenseCoach (CchID, StrategyID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Mike Brown'), (SELECT StrategyID FROM Strategy WHERE StrategyID = 3));
INSERT INTO ShootingCoach (CchID, ShootingID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Joseph Mazzulla'), (SELECT ShootingID FROM Shooting WHERE ShootingID = 1));
INSERT INTO ShootingCoach (CchID, ShootingID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Steve Kerr'), (SELECT ShootingID FROM Shooting WHERE ShootingID = 2));
INSERT INTO ShootingCoach (CchID, ShootingID)
VALUES ((SELECT CchID FROM Coaches WHERE CchName = 'Mike Brown'), (SELECT ShootingID FROM Shooting WHERE ShootingID = 3));

INSERT INTO Games VALUES
(UUID(), '2022-10-19', 'Warriors', 'Lakers', 123, 109, NULL);
INSERT INTO Games VALUES
(UUID(), '2023-02-12', 'Warriors', 'Lakers', 103, 109, NULL);
INSERT INTO Games VALUES
(UUID(), '2023-02-24', 'Lakers', 'Warriors', 124, 111, NULL);
INSERT INTO Games VALUES
(UUID(), '2023-03-06', 'Lakers', 'Warriors', 113, 105, NULL);

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

INSERT INTO Player_Attend_Game VALUES
(UUID(), (SELECT PlyID FROM Players WHERE PlyName = 'Lebron James'), (SELECT GameID FROM Games WHERE GameDate = '2022-10-19'));
INSERT INTO Player_Attend_Game VALUES
(UUID(), (SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry'), (SELECT GameID FROM Games WHERE GameDate = '2022-10-19'));
INSERT INTO Player_Attend_Game VALUES
(UUID(), (SELECT PlyID FROM Players WHERE PlyName = 'Jordan Poole'), (SELECT GameID FROM Games WHERE GameDate = '2022-10-19'));

INSERT INTO Injury (InjType, InjPosition, InjStatus)
VALUES ('Sprained', 'Right ankle', 'Out');
INSERT INTO Injury (InjType, InjPosition, InjStatus)
VALUES ('Sprained', 'Right Knee', 'Probable');
INSERT INTO Injury (InjType, InjPosition, InjStatus)
VALUES ('Strained', 'Left ankle', 'Probable');
INSERT INTO Injury (InjType, InjPosition, InjStatus)
VALUES ('Sore', 'Lower Back', 'Questionable');

INSERT INTO InjuryReport (InjureID, InjuryID, PlyID)
VALUES (UUID(), (SELECT InjuryID FROM Injury WHERE InjuryID = 1), (SELECT PlyID FROM Players WHERE PlyName = 'Stephen Curry'));
INSERT INTO InjuryReport (InjureID, InjuryID, PlyID)
VALUES (UUID(), (SELECT InjuryID FROM Injury WHERE InjuryID = 2), (SELECT PlyID FROM Players WHERE PlyName = 'Jordan Poole'));
INSERT INTO InjuryReport (InjureID, InjuryID, PlyID)
VALUES (UUID(), (SELECT InjuryID FROM Injury WHERE InjuryID = 3), (SELECT PlyID FROM Players WHERE PlyName = 'Lebron James'));

/* create two views */
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

/* select from all tables and views */
SELECT * FROM self;
SELECT * FROM Teams;
SELECT * FROM Players;
SELECT * FROM TwoWayContractPlayers;
SELECT * FROM NormalContractPlayers;
SELECT * FROM Spokesman;
SELECT * FROM Managers;
SELECT * FROM Coaches;
SELECT * FROM Tactics;
SELECT * FROM Strategy;
SELECT * FROM Shooting;
SELECT * FROM OffenseCoach;
SELECT * FROM DefenseCoach;
SELECT * FROM ShootingCoach;
SELECT * FROM Games;
SELECT * FROM Team_Play_Game;
SELECT * FROM Player_Attend_Game;
SELECT * FROM Injury;
SELECT * FROM InjuryReport;
SELECT * FROM LakersMember;
SELECT * FROM WarriorsMember;

/* drop database */
-- DROP DATABASE nba2223season;
