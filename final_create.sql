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
    FOREIGN KEY (assignment_name) REFERENCES Assignment(assignment_name)
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

-- show categories for current (given) class
DELIMITER //
CREATE PROCEDURE showCategories( 
	IN classId VARCHAR(32)
)
BEGIN
    SELECT category_name, weight FROM Category WHERE course_number = classNum;
END //
    
DELIMITER ;


