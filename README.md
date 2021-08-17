# Student Registration System

*Implement Oracle's PL/SQL and JDBC to create an application to support typical student registration tasks in a university*
***

## Tables
The following tables from the Student Registration System will be used in this project:
* Students(B#, first_name, last_name, status, gpa, email, bdate, deptname)
* TAs(B#, ta_level, office)
* Courses(dept_code, course#, title)
* Classes(classid, dept_code, course#, sect#, year, semester, limit, class_size, room, TA_B#)
* Enrollments(B#, classid, lgrade)
* Prerequisites(dept_code, course#, pre_dept_code, pre_course#)

In addition, the following table is also required for this project:
* Logs(log#, op_name, op_time, table_name, operation, key_value)

Each tuple in the logs table describes who `(op_name - the login name of a database user)` has performed what operation (insert, delete, update) on which table (table_name) and which tuple (as indicated by the value of the primary key of the tuple) at what time `(op_time)`. Attribute `log#` is the primary key of the table.

****
## PL/SQL Implementation
*Created a PL/SQL package for this application, following requirements and functionalities are implemented*
* Use a sequence to generate the values for log# automatically when new log records are inserted into the logs table. 
* Display the tuples in each of the seven tables for this project. 
* For a given class, will list the Id, the first name and last name of the TA of the class. 
* For a given course,will return all its prerequisite courses, including both direct and indirect prerequisite courses. 
* Enroll a student into a class. 
* Drop a student from a class. 
* Delete a student from the Students table based on a given ID.
* Add tuples to the Logs table automatically whenever a student is deleted from the Students table, or when a student is successfully enrolled into or dropped from a class 

***
## UI
*Implement an interactive and menu-driven interface in the bingsuns environment using Java and JDBC*

The basic requirement for the UI is a text-based menu-driven interface. It displays menu options for a user to select. An option may have sub-options depending on requirements. Once a final option is selected, the interface may prompt the user to enter parameter values from the terminal. As an example, for enrolling a student into a class, the parameter values include StudentID and classid. Then an operation corresponding to the selected option will be performed with appropriate message displayed.
