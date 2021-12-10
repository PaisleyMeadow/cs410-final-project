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
--      * assign the grade ‘grade’ for student
--         with user name ‘username’ for assignment ‘assignmentname’. If the student already has a
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

-- Call assignGrade('hvxqer8573', 'asdf', 78, 2, @result);