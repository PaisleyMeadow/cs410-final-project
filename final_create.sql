CREATE TABLE Class ( 
	course_id INT AUTO_INCREMENT NOT NULL, 
	course_number VARCHAR(32) UNIQUE NOT NULL,    
	term VARCHAR(32) NOT NULL, 
    section INT NOT NULL, 
    class_desc TEXT,
    
    PRIMARY KEY (course_id)
);

CREATE TABLE Category ( 
	category_id INT AUTO_INCREMENT NOT NULL,
    category_name VARCHAR(64) NOT NULL,
    weight DOUBLE,
    course_number VARCHAR(32) NOT NULL,
    
    FOREIGN KEY (course_number) REFERENCES Class(course_number),
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
    course_number VARCHAR(32) NOT NULL,
    
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_number) REFERENCES Class(course_number)
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
    INSERT INTO Class VALUES (classNum, classTerm, classSection, classDesc);
END //
    
DELIMITER ;

-- selects the only section of class in the most recent term, if there is only one such section; if there are multiple sections it fails. 
-- first, get class adfadf figure this bullshit out later...

-- show categories for current (given) class
DELIMITER //
CREATE PROCEDURE showCategories( 
	IN classId VARCHAR(32)
)
BEGIN
    SELECT category_name, weight FROM Category WHERE course_number = classNum;
END //
    
DELIMITER ;


CALL createClass("TEST100", "F20", 1, "A test class.");
