#Create test class
INSERT INTO Class (course_number, term, section, class_desc) VALUES ("CS410", "Fa21", "1", "Databases");

#Create test categories
INSERT INTO Category (category_name, weight, course_id) VALUES ("Homework", 35, 1);
INSERT INTO Category (category_name, weight, course_id) VALUES ("Project", 15, 1);
INSERT INTO Category (category_name, weight, course_id) VALUES ("Midterm", 30, 1);
INSERT INTO Category (category_name, weight, course_id) VALUES ("Final", 20, 1);
SELECT * FROM Category;

#Create test assignments
INSERT INTO Assignment (assignment_name, assignment_description, points, category_id) VALUES ("Homework 1", "Entity-Relation Modeling", 100, 1);
INSERT INTO Assignment (assignment_name, assignment_description, points, category_id) VALUES ("Homework 2", "SQL 'charity' Database", 100, 1);
INSERT INTO Assignment (assignment_name, assignment_description, points, category_id) VALUES ("Homework 3", "Data to SQL", 100, 1);
INSERT INTO Assignment (assignment_name, assignment_description, points, category_id) VALUES ("Final Project", "JDBC command line interaction", 100, 2);
INSERT INTO Assignment (assignment_name, assignment_description, points, category_id) VALUES ("Midterm 1", "Test covering first half of semester", 100, 3);
INSERT INTO Assignment (assignment_name, assignment_description, points, category_id) VALUES ("Midterm 2", "Test covering second half of semester", 100, 3);
INSERT INTO Assignment (assignment_name, assignment_description, points, category_id) VALUES ("Final Exam", "Test covering all material", 100, 4);
SELECT * FROM Assignment;

#Create test students
insert into Student (username, student_name) values ('opallangdale', 'Langdale, Opal');
insert into Student (username, student_name) values ('bsherman', 'Sherman, Ben');
insert into Student (username, student_name) values ('qadams', 'Adams, Quincy');
insert into Student (username, student_name) values ('hughman', 'Jackman, Hugh');
insert into Student (username, student_name) values ('mandm', 'Mathers, Mike');
insert into Student (username, student_name) values ('seekercypher', 'Cypher, Richard');
insert into Student (username, student_name) values ('bashman', 'Fox, Brian');
insert into Student (username, student_name) values ('oliviaramey', 'Ramey, Olivia');
insert into Student (username, student_name) values ('jackiebriar', 'Briar, Jackie');
insert into Student (username, student_name) values ('lowellhart', 'Hart, Lowell');
insert into Student (username, student_name) values ('kwest', 'West, Kevin');
insert into Student (username, student_name) values ('chbrown', 'Brown, Chester');
insert into Student (username, student_name) values ('bigdawgemmett', 'Hoff, Emmett');
insert into Student (username, student_name) values ('joegreen', 'Green, Joe');
insert into Student (username, student_name) values ('vivianpowers', 'Powers, Vivian');

#Enroll test students in CS410
INSERT INTO Enrolled (student_id, course_id) VALUES (1, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (2, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (3, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (4, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (5, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (6, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (7, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (8, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (9, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (10, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (11, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (12, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (13, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (14, 1);
INSERT INTO Enrolled (student_id, course_id) VALUES (15, 1);

SELECT * FROM Submitted;

#Create grades for each assignment/student pair
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (1,1,"72"), 
  (1,2,"81"), 
  (1,3,"52"), 
  (1,4,"72"), 
  (1,5,"58"), 
  (1,6,"66"), 
  (1,7,"79");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (2,1,"59"),
  (2,2,"77"),
  (2,3,"69"),
  (2,4,"88"),
  (2,5,"75"),
  (2,6,"81"),
  (2,7,"74");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (3,1,"60"),
  (3,2,"91"),
  (3,3,"84"),
  (3,4,"60"),
  (3,5,"58"),
  (3,6,"69"),
  (3,7,"48");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (4,1,"79"),
  (4,2,"65"),
  (4,3,"66"),
  (4,4,"82"),
  (4,5,"51"),
  (4,6,"56"),
  (4,7,"58");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (5,1,"65"),
  (5,2,"75"),
  (5,3,"83"),
  (5,4,"52"),
  (5,5,"46"),
  (5,6,"54"),
  (5,7,"62");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (6,1,"58"),
  (6,2,"80"),
  (6,3,"65"),
  (6,4,"66"),
  (6,5,"76"),
  (6,6,"53"),
  (6,7,"78");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (7,1,"51"),
  (7,2,"63"),
  (7,3,"65"),
  (7,4,"76"),
  (7,5,"73"),
  (7,6,"69"),
  (7,7,"55");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (8,1,"77"),
  (8,2,"52"),
  (8,3,"48"),
  (8,4,"69"),
  (8,5,"80"),
  (8,6,"73"),
  (8,7,"69");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (9,1,"73"),
  (9,2,"59"),
  (9,3,"74"),
  (9,4,"53"),
  (9,5,"40"),
  (9,6,"87"),
  (9,7,"57");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (10,1,"71"),
  (10,2,"62"),
  (10,3,"87"),
  (10,4,"75"),
  (10,5,"84"),
  (10,6,"73"),
  (10,7,"63");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (11,1,"92"),
  (11,2,"74"),
  (11,3,"57"),
  (11,4,"54"),
  (11,5,"60"),
  (11,6,"67"),
  (11,7,"72");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (12,1,"74"),
  (12,2,"45"),
  (12,3,"74"),
  (12,4,"82"),
  (12,5,"82"),
  (12,6,"62"),
  (12,7,"71");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (13,1,"61"),
  (13,2,"81"),
  (13,3,"64"),
  (13,4,"87"),
  (13,5,"69"),
  (13,6,"85"),
  (13,7,"73");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (14,1,"68"),
  (14,2,"69"),
  (14,3,"50"),
  (14,4,"71"),
  (14,5,"72"),
  (14,6,"58"),
  (14,7,"73");
INSERT INTO Submitted (student_id, assignment_id, grade_value) VALUES (15,1,"65"),
  (15,2,"89"),
  (15,3,"65"),
  (15,4,"64"),
  (15,5,"69"),
  (15,6,"68"),
  (15,7,"63");