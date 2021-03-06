CREATE TABLE Class ( 
	course_id INT AUTO_INCREMENT NOT NULL, 
	course_number VARCHAR(32) NOT NULL,    
	term VARCHAR(32) NOT NULL, 
    section INT NOT NULL, 
    class_desc TEXT,
    
    PRIMARY KEY (course_id)
);

CREATE TABLE Category ( 
	category_id INT AUTO_INCREMENT NOT NULL,
    category_name VARCHAR(64) NOT NULL,
    weight DOUBLE,
    course_id INT NOT NULL,
    
    FOREIGN KEY (course_id) REFERENCES Class(course_id),
    PRIMARY KEY (category_id)
);

CREATE TABLE Assignment ( 
	assignment_id INT AUTO_INCREMENT NOT NULL,
	assignment_name VARCHAR(128) UNIQUE NOT NULL, 
    assignment_description TEXT,
    points INT NOT NULL, 
    category_id INT NOT NULL, 
    
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    PRIMARY KEY (assignment_id)
);

CREATE TABLE Student ( 
	student_id INT AUTO_INCREMENT NOT NULL,
    username VARCHAR(64) UNIQUE NOT NULL, 
    student_name VARCHAR(64),
    
    PRIMARY KEY (student_id)
);

CREATE TABLE Enrolled ( 
	student_id INT NOT NULL, 
    course_id INT NOT NULL,
    
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Class(course_id)
);

CREATE TABLE Submitted ( 
	student_id INT NOT NULL,
    assignment_id INT NOT NULL,
    grade_value INT,
    
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (assignment_id) REFERENCES Assignment(assignment_id),
    
    PRIMARY KEY (student_id, assignment_id)
);

-- create a new class 
DELIMITER //
CREATE PROCEDURE createClass( 
	IN classNum VARCHAR(32), IN classTerm VARCHAR(32), IN classSection INT, classDesc TEXT
)
BEGIN
    INSERT INTO Class (course_number, term, section, class_desc) 
    VALUES (classNum, classTerm, classSection, classDesc);
END //
    
DELIMITER ;

-- selects class (for active class)
DELIMITER $$

CREATE PROCEDURE selectClass(
	IN pnumber VARCHAR(32), pterm VARCHAR(32), psection INT
)
BEGIN
IF pterm IS NULL THEN

	SELECT course_id, course_number FROM Class 
    WHERE course_number = pnumber 
    AND CAST(SUBSTR(term, 3, 4) AS SIGNED) =
		( SELECT MIN(CAST(SUBSTR(term, 3, 4) AS SIGNED)) FROM Class WHERE course_number = pnumber);

ELSEIF psection IS NULL THEN

	SELECT course_id, course_number FROM Class WHERE course_number = pnumber AND term = pterm;

ELSE
	SELECT course_id, course_number FROM Class WHERE course_number = pnumber AND term = pterm AND section = psection;
END IF;

END$$

DELIMITER ;

-- Select all students for active class
DELIMITER $$
CREATE PROCEDURE selectAllStudents(IN cid INT)
BEGIN
    SELECT student_name, username FROM Student NATURAL JOIN Enrolled
        WHERE Enrolled.course_id = cid;
END$$
DELIMITER ;

-- select students with string (unsure if supposed to be for active class)
DELIMITER $$
CREATE PROCEDURE selectStudents(IN str VARCHAR(64), cid INT)
BEGIN 
	SELECT student_name, username FROM Student NATURAL JOIN Enrolled 
		WHERE (LOWER(student_name) LIKE str OR LOWER(username) LIKE str) 
        AND Enrolled.course_id = cid;
END$$

DELIMITER ;

-- grade assignmentname username grade
--      * assign the grade ???grade??? for student
--         with user name ???username??? for assignment ???assignmentname???. If the student already has a
--         grade for that assignment, replace it. If the number of points exceeds the number of
--         points configured for the assignment, print a warning (showing the number of points
--         configured)

DELIMITER $$

CREATE PROCEDURE assignGrade(
	IN uname VARCHAR(64), aname VARCHAR(128), grade INT, classId INT, OUT result INT
)
BEGIN

DECLARE sid INT DEFAULT 0;
DECLARE aid INT DEFAULT 0;

-- get student id
SELECT student_id INTO sid FROM Student NATURAL JOIN Enrolled WHERE username = uname AND course_id = classId;

-- get assignment id
SELECT assignment_id INTO aid FROM Assignment NATURAL JOIN Category WHERE assignment_name = aname AND course_id = classId;

IF sid = 0 THEN
	SET result = -1;
ELSEIF aid = 0 THEN 
	SET result = -2;
ELSE
	INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (sid, aid, grade) ON DUPLICATE KEY UPDATE grade_value = grade;
	
    SELECT points INTO result FROM Assignment WHERE assignment_id = aid AND points < grade;
END IF;

SELECT result;

END$$

DELIMITER ;

-- For reporting grades, calculate grades out of 100. Rescale category weights so they sum to 100;
--         within each category, compute the fraction of possible points a student has achieved (divide their
--         total grade points in that category by the total possible points based on assignment point counts).
--         
--         For both student-grades and gradebook, report grades two ways: a totalgrade, based on
--         total possible points (including assignments for which the student does not have a grade at all),
--         and an attemptedgrade, that is based on the point values of the assignments for which they have
--         a grade.
--      */
-- **
--      * student-grades <username> ??? show student???s current grade: all assignments, visually
--      * grouped by category, with the student???s grade (if they have one). Show subtotals for each
--      * category, along with the overall grade in the class.
-- "My understanding for the grade calculation is that you would add up ((all points scored/ all possible points) * category_weight) for each category
-- And if the category weights don't add to 100, or are over 100: you would just do (category_weight/total_weight_all_categories) instead of category weight"

DELIMITER $$

CREATE PROCEDURE showStudentGrades(
	IN uname VARCHAR(64), cid INT
)
this_proc: BEGIN

DECLARE sid INT DEFAULT 0;
DECLARE total_weight INT DEFAULT 0;
DECLARE total_cat_points INT DEFAULT 0;

-- get student id
SELECT student_id INTO sid FROM Student NATURAL JOIN Enrolled WHERE username = uname AND course_id = cid;

IF sid = 0 THEN
	SELECT sid; 
	LEAVE this_proc;
END IF;

-- check if category weights add up to 100
SELECT SUM(weight) INTO total_weight FROM Category NATURAL JOIN Class WHERE course_id = cid;

IF total_weight = 100 THEN
	SET total_weight = 1;
END IF;

SELECT assignment_name, grade_value AS Grade, points as Total, weight/total_weight AS Weight, category_name, category_id AS catId,
	(SELECT SUM(points) FROM Assignment NATURAL JOIN Category GROUP BY category_id HAVING category_id = catId) AS catTotal
	FROM Assignment 
		NATURAL JOIN Submitted
		NATURAL JOIN Category 
    WHERE student_id = sid AND course_id = cid
    GROUP BY category_name, assignment_name;

END$$

DELIMITER ;

DELIMITER $$

-- gradebook ??? show the current class???s gradebook: students (username, student ID, and
-- name), along with their total grades in the class.
CREATE PROCEDURE showGrades(
	IN cid INT
)	
this_proc: BEGIN

DECLARE sid INT DEFAULT 0;

SELECT username, student_id, student_name, (SUM(grade_value)/SUM(points)) as Grade 
	FROM Student 
		NATURAL JOIN Submitted
        NATURAL JOIN Assignment 
        NATURAL JOIN Category
        NATURAL JOIN Class
	WHERE course_id = 1
    GROUP BY username;

END$$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE createCategory(IN catName VARCHAR(64), catWeight DOUBLE, classID INT)
BEGIN
    INSERT INTO Category (category_name, weight, course_id)
    VALUES (catName, catWeight, classID);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE createAssignment(IN assignName VARCHAR(128), catName VARCHAR(64), assignDesc TEXT, assignPoints INT, classID INT)
BEGIN
    -- get the category id from the name they specified and the current active class
    DECLARE cid INT DEFAULT -1;
    SELECT category_id INTO cid FROM Category WHERE category_name = catName AND course_id = classID;

    INSERT INTO Assignment (assignment_name, assignment_description, points, category_id)
    VALUES (assignName, assignDesc, assignPoints, cid);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE createStudent(IN uname VARCHAR(64), studentID INT, lastName VARCHAR(31), firstName VARCHAR(31))
BEGIN
    DECLARE fullName VARCHAR(64);
    SELECT CONCAT(lastName, ", ", firstName) INTO fullName;
    INSERT INTO Student (username, student_name)
    VALUES (uname, fullName);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE updateStudent(IN studentID INT, fullName VARCHAR(64))
BEGIN
    UPDATE Student 
    SET student_name = fullName
    WHERE student_id = studentID;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE enrollStudent(IN uname VARCHAR(64), classID INT)
BEGIN
    DECLARE stuID INT DEFAULT -1;
    SELECT student_id INTO stuID FROM Student WHERE username = uname;

    INSERT INTO Enrolled (student_id, course_id)
    VALUES (stuID, classID);
END$$
DELIMITER ;