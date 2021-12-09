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
	assignment_name VARCHAR(128) UNIQUE NOT NULL, 
    points INT NOT NULL, 
    category_id INT NOT NULL, 
    
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    PRIMARY KEY (assignment_name)
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
    assignment_name VARCHAR(128) NOT NULL,
    grade_value INT,
    
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (assignment_name) REFERENCES Assignment(assignment_name),
    
    PRIMARY KEY (student_id, assignment_name)
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

-- get student id
DECLARE sid INT DEFAULT 0;

SELECT student_id INTO sid FROM Student WHERE username = uname;

INSERT INTO Submitted (student_id, assignment_name, grade_value) VALUES (sid, aname, grade) ON DUPLICATE KEY UPDATE grade_value = grade;

SELECT points INTO result FROM Assignment WHERE assignment_name = aname AND points < grade;

SELECT result;

END$$

DELIMITER ;

Call assignGrade('hvxqer8573', 'Whiteflower Leafcup', 78, 2, @result);