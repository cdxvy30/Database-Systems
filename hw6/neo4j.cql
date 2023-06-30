-- Part II
-- task 1
-- have to move files into /neo4j-community-v5.8.0/import first
LOAD CSV WITH HEADERS FROM 'file:///DBMS_student_list.csv' AS row
CREATE (:Student { 身份: row.身份, 系所: row.系所, 年級: row.年級, 學號: row.學號, 姓名: row.姓名, 信箱: row.信箱, 班別: row.班別 });

-- task 2
MATCH (s:Student { 學號: 'R11521603' })
SET s.group = 2
RETURN s;

MATCH (s1:Student { 學號: 'R11521613' })
MATCH (s2:Student { 學號: 'R11521616' })
MATCH (s3:Student { 學號: 'R10724039' })
MATCH (s4:Student { 學號: 'R11944022' })
SET s1.group = 2, s2.group = 2, s3.group = 2, s4.group = 2
RETURN s1, s2, s3, s4;

-- task 3
MATCH (s:Student { group: 2 })
RETURN s;

-- Part III
-- task 1
LOAD CSV WITH HEADERS FROM 'file:///hw6_hobbies.csv' AS row
UNWIND [row.hobby1, row.hobby2, row.hobby3, row.hobby4, row.hobby5] AS hobby
MERGE (h:Hobby { name: hobby })
WITH h, hobby, row
MATCH (s:Student)
WHERE s.學號 = row.學號
WITH s, [row.hobby1, row.hobby2, row.hobby3, row.hobby4, row.hobby5] AS hobbies
UNWIND hobbies AS hobby
MATCH (h:Hobby { name: hobby })
MERGE (s)-[:HAS_HOBBY]->(h);

-- task 2
MATCH (me:Student)-[:HAS_HOBBY]->(myHobby:Hobby)
WITH me, myHobby
WHERE me.學號 = "R11521603"
MATCH (me)-[:HAS_HOBBY]->(myHobby:Hobby)<-[:HAS_HOBBY]-(friend:Student)-[:HAS_HOBBY]->(friendHobby:Hobby)
WITH me, myHobby, friend, friendHobby
WHERE NOT friendHobby.name IN ["travelling", "basketball", "coding", "soccer", "guitar"]
RETURN friend, friendHobby;

-- task 3
MATCH (me:Student)-[:HAS_HOBBY]->(myHobby:Hobby)
WITH me, myHobby
WHERE me.學號 = "R11521603"
MATCH (me)-[:HAS_HOBBY]->(myHobby:Hobby)<-[:HAS_HOBBY]-(friend:Student)-[:HAS_HOBBY]->(friendHobby:Hobby)
WITH COLLECT(DISTINCT friend) AS friends
WITH COLLECT(DISTINCT friendHobby) AS friendHobbies
MATCH (friend)-[:HAS_HOBBY]->(commonHobby:Hobby)<-[:HAS_HOBBY]-(foaf:Student)-[:HAS_HOBBY]->(newHobby:Hobby)
WHERE NOT foaf IN friends AND NOT commonHobby IN friendHobbies
RETURN foaf, COLLECT(DISTINCT newHobby) AS newHobbies

-- task 4
MATCH (me:Student)-[:HAS_HOBBY]->(myHobby:Hobby)
WHERE me.學號 = "R11521603"
MATCH (me)-[:SAME_GROUP]->(group:Group)<-[:SAME_GROUP]-(groupMember:Student)

MATCH (groupMember)-[:HAS_HOBBY]->(:Hobby)<-[:HAS_HOBBY]-(hobbyFriend:Student)
WHERE hobbyFriend <> me

// Find "foaf2" who are hobby friends of group members
MATCH (hobbyFriend)-[:HAS_HOBBY]->(commonHobby:Hobby)<-[:HAS_HOBBY]-(foaf2:Student)
WHERE foaf2 <> me
  AND NOT (me)-[:HAS_HOBBY]->(commonHobby)
  AND NOT (hobbyFriend)-[:HAS_HOBBY]->(commonHobby)
  AND NOT (me)-[:IN_PROJECT_GROUP]->(:Group)<-[:IN_PROJECT_GROUP]-(foaf2)

RETURN foaf2;

-- task 5
