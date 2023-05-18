/***** use database *****/
USE DB_class;

/***** info *****/
CREATE TABLE self (
  StuID varchar(10) NOT NULL,
  Department varchar(10) NOT NULL,
  SchoolYear int DEFAULT 1,
  Name varchar(10) NOT NULL,
  PRIMARY KEY (StuID)
);

INSERT INTO self
VALUES ('r11521603', '土木系電輔組', 1, '陳冠錞');

SELECT DATABASE();
SELECT * FROM self;

/* Prepared statement */
PREPARE select_statement FROM 'SELECT * FROM student WHERE 系所 = ?';
SET @myDept = '土木系電輔組';
EXECUTE select_statement USING @myDept;
SET @otherDept = '資工系';
EXECUTE select_statement USING @otherDept;

/* Stored-function */
DELIMITER //
CREATE FUNCTION extract_chinese_name(full_name VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE chinese_part VARCHAR(255);
  
  SET chinese_part = REGEXP_REPLACE(full_name, '[^\\p{Han}]', '');
  
  RETURN chinese_part;
END //
DELIMITER ;
SELECT extract_chinese_name(姓名) AS chinese_name FROM student;

DELIMITER //
CREATE FUNCTION extract_english_name(full_name VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE english_part VARCHAR(255);
  SET english_part = TRIM(TRAILING ')' FROM SUBSTRING_INDEX(full_name, '(', -1));
  IF english_part = full_name THEN
    SET english_part = '';
  END IF;
  RETURN english_part;
END //
DELIMITER ;
SELECT extract_english_name(姓名) AS english_name FROM student;

SELECT extract_chinese_name(姓名) AS chinese_name, extract_english_name(姓名) AS english_name
FROM student;

/* Stored procedure */
DELIMITER //
CREATE PROCEDURE count_students_in_dept(IN dept_name VARCHAR(255), OUT st_count INT)
BEGIN
  DECLARE dept_count INT;
  
  SELECT COUNT(*) INTO dept_count FROM student WHERE 系所 = dept_name;
  
  SET st_count = dept_count;
END //
DELIMITER ;

CALL count_students_in_dept('土木系電輔組', @STCOUNT);
SELECT @STCOUNT;
CALL count_students_in_dept('資工系', @STCOUNT);
SELECT @STCOUNT;

/* Trigger I  */
SET @NUMCAPS = 0;
DELIMITER //
CREATE TRIGGER update_num_caps AFTER UPDATE ON student
FOR EACH ROW
BEGIN
  IF NEW.final_captain = 'Y' THEN
    SET @NUMCAPS := (SELECT COUNT(*) FROM student WHERE final_captain = 'Y');
  END IF;
END //
DELIMITER ;

UPDATE student SET final_captain = 'Y' WHERE 學號 = 'B09902021';
UPDATE student SET final_captain = 'Y' WHERE 學號 = 'B09705059';
UPDATE student SET final_captain = 'Y' WHERE 學號 = 'R11921017';
UPDATE student SET final_captain = 'Y' WHERE 學號 = 'F08921a05';
UPDATE student SET final_captain = 'Y' WHERE 學號 = 'R11246002';
SELECT * FROM student WHERE final_captain = 'Y';
SELECT @NUMCAPS;

/* Trigger II */
CREATE TABLE record (
  id INT AUTO_INCREMENT PRIMARY KEY,
  operation_type VARCHAR(10),
  username VARCHAR(20),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER insert_monit
AFTER INSERT ON student
FOR EACH ROW
BEGIN
  INSERT INTO record (operation_type, username) VALUES ('INSERT', USER());
END //

CREATE TRIGGER delete_monit
AFTER DELETE ON student
FOR EACH ROW
BEGIN
  INSERT INTO record (operation_type, username) VALUES ('DELETE', USER());
END //
DELIMITER ;

INSERT INTO student VALUES ('學生', '生科所', 3, 'R11111111', '霍華德', 'howard@ntu.edu.tw', '資料庫系統-從SQL到NoSQL (EE5178)', 0, 'N');
INSERT INTO student VALUES ('學生', '生科所', 3, 'R22222222', '林書豪', 'jjlin@ntu.edu.tw', '資料庫系統-從SQL到NoSQL (EE5178)', 0, 'N');
INSERT INTO student VALUES ('學生', '生科所', 3, 'R33333333', '陳又瑋', 'yowei@ntu.edu.tw', '資料庫系統-從SQL到NoSQL (EE5178)', 0, 'N');
DELETE FROM student WHERE 學號 = 'R11111111';
DELETE FROM student WHERE 學號 = 'R22222222';

SELECT * FROM record;

/* drop database */
DROP DATABASE DB_class;