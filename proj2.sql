
set serveroutput on;

--1. log sequence (not in package)
drop SEQUENCE seq_name;
create sequence seq_name
start with 100
nomaxvalue
nocycle
noorder;

-- trigger
-- trigger
/*0. delete studnet records before delete student info*/
CREATE OR REPLACE TRIGGER del_student_in_enroll 
BEFORE DELETE ON students
FOR EACH ROW
declare
cursor cur1 is select B# from TAs;
BEGIN
	for cur1_rec in cur1 loop
		if (cur1_rec.B# = :OLD.b#) then
			update classes set TA_B# = null where TA_B# = :OLD.b#;
			delete from TAs where B# = :OLD.b#;
		end if;
	end loop;
	DELETE FROM enrollments WHERE B# = :OLD.b#;
	dbms_output.put_line('Delete student('||:old.b# ||') info in table enrollment');   
END;
/
show errors;

/* 1. delete student*/
CREATE OR REPLACE TRIGGER deleted_student 
AFTER DELETE ON students
FOR EACH ROW    
BEGIN
	INSERT INTO logs VALUES( seq_name.nextval, user, sysdate, 'Students', 'Delete',:old.b#);
END;
/
show errors;

/*2. add value in enrollments*/

CREATE OR REPLACE TRIGGER student_enroll_in 
AFTER INSERT ON enrollments
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES( seq_name.nextval, user, sysdate, 'Enrollments', 'Insert',:new.b#||','||:new.classid);
END;
/
show errors;

/* 3. delete values from enrollments*/
CREATE OR REPLACE TRIGGER student_enroll_out 
AFTER DELETE ON enrollments
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES(seq_name.nextval, user, sysdate, 'Enrollments', 'Delete',:old.b#||','||:old.classid);
END;
/
show errors;

create or replace trigger after_del_enroll 
after delete on enrollments
FOR EACH ROW
begin
	for cursor1 in ( select * from Classes c where c.classid = :old.classid)
	loop
		if (cursor1.class_size > 0) then
			update Classes set class_size = class_size - 1 where classid = cursor1.classid;
			dbms_output.put_line('class '||cursor1.classid||' size decrease.');
		end if;
	end loop;
end;
/
show errors;


create or replace trigger after_add_enroll 
after insert on enrollments
FOR EACH ROW
begin
	for cursor1 in ( select * from Classes c where c.classid = :new.classid)
	loop
		if (cursor1.class_size >= 0) then
			update Classes set class_size = class_size + 1 where classid = cursor1.classid;
			dbms_output.put_line('class '||cursor1.classid||' size decrease.');
		end if;
	end loop;
end;
/
show errors;

--package


create or replace package proj2 as
PROCEDURE show_students(c1 out sys_refcursor);
PROCEDURE show_tas(c1 out sys_refcursor);
PROCEDURE show_classes(c1 out sys_refcursor);
PROCEDURE show_courses(c1 out sys_refcursor);
PROCEDURE show_enrollments(c1 out sys_refcursor);
PROCEDURE show_logs(c1 out sys_refcursor);
PROCeDURE show_prerequisites(c1 out sys_refcursor);
procedure find_tas(v_classid in classes.classid%type, result OUT varchar2);
procedure find_precourses(v_dept_code in varchar2, v_course# in number,result1 out varchar2,result2 out varchar2);
procedure add_enroll(v_B# in students.b# %TYPE, v_classid in classes.classid %TYPE,result out varchar2);
procedure drop_students( v_B# in students.b#%type, v_classid in classes.classid%type, result out varchar2);
PROCEDURE student_delete( student_id in students.b#%type, result out varchar2);

end;
/

show errors;


create or replace package body proj2 as

--2.
procedure show_students(c1 out sys_refcursor)
is
begin
	open c1 for select * from students;
end;

procedure show_tas(c1 out sys_refcursor)
is
begin
	open c1 for select * from tas;
end;

PROCEDURE show_classes(c1 out sys_refcursor)
is
begin
	open c1 for select * from classes;
end;

PROCEDURE show_courses(c1 out sys_refcursor)
is
begin
	open c1 for select * from courses;
end;
PROCEDURE show_enrollments(c1 out sys_refcursor)
is
begin 
	open c1 for select * from enrollments;
end;

PROCEDURE show_logs(c1 out sys_refcursor)
is
begin 
	open c1 for select * from logs;
end;
PROCeDURE show_prerequisites(c1 out sys_refcursor)
is 
begin 
	open c1 for select * from prerequisites;
end;





--3
procedure find_tas(v_classid in classes.classid%type, result out varchar2)
is
v_match boolean;
v_B# students.B#%type;
v_first_name students.first_name%type;
v_last_name students.last_name%type;
cursor c8 is select classid from classes;
c8_rec c8%rowtype;
invalid_classid exception;
begin
	result:= '';
	v_match := false;
    
	for c8_rec in c8 loop
	if  (v_classid = c8_rec.classid) then
			v_match := true;
	end if;
	end loop;
    
	if( v_match = false )then
		raise invalid_classid;
	end if;

	select s.B#,s.first_name,s.last_name into v_B#,v_first_name,v_last_name from students s, classes c where c.classid = v_classid and c.ta_B# = s.B#;
	result := 'TA B# = ' || v_B# || ', first_name = ' || v_first_name ||', last_name = '|| v_last_name;
exception
	when no_data_found then 
		result :='The class has no TA.';
	when invalid_classid then
		result := 'The class is invalid.';

end;







--4.
procedure find_precourses(v_dept_code in varchar2, v_course# in number,result1 out varchar2,result2 out varchar2)
is
v_match1 boolean;
v_invalid_match boolean;
ind_state boolean;
cursor c9 is select dept_code,course# from prerequisites;
cursor c22 is select dept_code,course# from Classes;
invalid_input exception;
e_no_pre exception;
v_pre_indcode prerequisites.dept_code%type;
v_pre_indc# prerequisites.course#%type;
v_pre_dcode prerequisites.dept_code%type;
v_pre_c# prerequisites.course#%type;
c9_rec c9%rowtype;
c22_rec c22%rowtype;
begin
	result1:='';
    result2:='';
	v_match1 := false;
	ind_state := false;
	v_invalid_match := false;

	for c22_rec in c22 loop
	if  (c22_rec.dept_code = v_dept_code) and (c22_rec.course# = v_course#) then
			v_invalid_match := true;
	end if;
	end loop;

	if(v_invalid_match = false) then
		raise invalid_input;
	end if;

	for c9_rec in c9 loop
	if  (c9_rec.dept_code = v_dept_code) and (c9_rec.course# = v_course#) then
			v_match1 := true;
			select pre_dept_code,pre_course# into v_pre_dcode,v_pre_c# from prerequisites where dept_code = v_dept_code and course# = v_course#;
	end if;
	end loop;
		
	if(v_match1 = false) then
		raise e_no_pre;
	end if;
	
   	for c9_rec in c9 loop
	if  (c9_rec.dept_code = v_pre_dcode) and (c9_rec.course# = v_pre_c#) then
			ind_state := true;
			select pre_dept_code,pre_course# into v_pre_indcode,v_pre_indc# from prerequisites where dept_code = v_pre_dcode and course# = v_pre_c#;
	end if;
	end loop;
    
    

	if (ind_state = true) then
		result1:= v_dept_code|| v_course# ||'s direct prerequisites is '||v_pre_dcode||v_pre_c#;
		result2:=v_dept_code|| v_course# ||'s indirect prerequisites is '||v_pre_indcode||v_pre_indc#;
	else
		result1 := v_dept_code|| v_course# ||' s direct prerequisites is '||v_pre_dcode||v_pre_c#;
		result2 := v_dept_code|| v_course# ||'do not have an indirect course.';
	end if;
exception
	when invalid_input then
		result1 := v_dept_code || v_course# ||' does not exist.';
	when e_no_pre then
		result1 := v_dept_code || v_course# ||' does not have prerequisites.';
end;



 procedure add_enroll
( v_B# in students.b# %TYPE, v_classid in classes.classid %TYPE,result out varchar2) 
is
v_B#_match boolean;
v_classid_match boolean;
v_sem_match boolean;
v_limit_match boolean;
v_already_match boolean;
v_prereq_match1 boolean;
v_tem_dcode prerequisites.pre_dept_code%type;
v_tem_c# prerequisites.pre_course#%type;
v_classid1 Classes.classid%type;
v_classid2 Classes.classid%type;
v_count number;

cursor c15 is select B# from students;
cursor c16 is select classid from Classes;
cursor c17 is select classid from Classes where year = 2018 and semester = 'Fall';
cursor c18 is select c.limit,c.class_size from Classes c where classid  = v_classid;
cursor c19 is select B#,classid from Enrollments;
cursor c20 is select classid from Classes where year = (select year from Classes where classid = v_classid) and semester = (select semester from Classes where classid = v_classid);
cursor c21 is select classid from Enrollments where B# = v_B#;



c15_rec c15%rowtype;
c16_rec c16%rowtype;
c17_rec c17%rowtype;
c18_rec c18%rowtype;
c19_rec c19%rowtype;
c20_rec c20%rowtype;
c21_rec c21%rowtype;

e_invalid_input1 exception;
e_invalid_input2 exception;
e_invalid_input3 exception;
e_full_size exception;
e_already_reg exception;
e_prereq1 exception;
begin
	v_count := 0;
	v_B#_match := false;
	v_classid_match := false;
	v_sem_match := false;
	v_limit_match := false;
	v_prereq_match1 := false;
    result := '';
	
	for c15_rec in c15 loop
	if  (c15_rec.B# = v_B#) then
			v_B#_match := true;
	end if;
	end loop;
	
	if( v_B#_match = false )then
		raise e_invalid_input1;
	end if;

	for c16_rec in c16 loop
	if  (c16_rec.classid= v_classid) then
			v_classid_match := true;
	end if;
	end loop;

	if( v_classid_match = false )then
		raise e_invalid_input2;
	end if;

	for c17_rec in c17 loop
	if  (c17_rec.classid= v_classid) then
			v_sem_match := true;
	end if;
	end loop;

	if( v_sem_match = false )then
		raise e_invalid_input3;
	end if; 

	for c18_rec in c18 loop
	if  (c18_rec.limit = c18_rec.class_size) then
			v_limit_match := true;
	end if;
	end loop;

	if( v_limit_match = true )then
		raise e_full_size;
	end if; 

	for c19_rec in c19 loop
	if  (c19_rec.B# = v_B#) and (c19_rec.classid = v_classid) then
			v_already_match := true;
	end if;
	end loop;

	if( v_already_match = true)then
		raise e_already_reg;
	end if; 


	for c19_rec in c19 loop
		for c20_rec in c20 loop
			if (c19_rec.B# = v_B#) and (c19_rec.classid = c20_rec.classid) then
				v_count := v_count + 1;
			end if;
		end loop;
	end loop;

	if( v_count = 4 )then
		result := 'The student will be overloaded with the new enrollment.';
		insert into enrollments values (v_B#, v_classid,null);
        commit;
	ELSIF (v_count = 5) then 
		result := 'Students cannot be enrolled in more than five classes in the same semester.';
	ELSIF (v_count <4) then
		insert into enrollments values (v_B#, v_classid,null);
        commit;
        result := 'Enrollment success';
	end if;

	select p.pre_dept_code,p.pre_course# into v_tem_dcode,v_tem_c# from prerequisites p,Classes c where v_classid = c.classid and c.dept_code = p.dept_code and c.course# = p.course#;
	select classid into v_classid1 from Classes where dept_code = v_tem_dcode and course# = v_tem_c# and sect# = 1;
	if (v_tem_c# = 314) then 
		select classid into v_classid2 from Classes where dept_code = v_tem_dcode and course# = v_tem_c# and sect# = 2;
	end if;
	for c21_rec in c21 loop
	if  (c21_rec.classid = v_classid1) or (c21_rec.classid = v_classid2) then
			v_prereq_match1 := true;
	end if;
	end loop;

	if( v_already_match = false)then
		raise e_prereq1;
	end if; 
    
    
exception
	when e_invalid_input1 then
		result := 'The B# is invalid.';
	when e_invalid_input2 then
		result := 'The classid is invalid.';
	when e_invalid_input3 then
		result := 'Cannot enroll into a class from a previous semester.';
	when e_full_size then
		result := 'The class is already full.';
	when e_already_reg then
		result := 'The student is already in the class.';
	when e_prereq1 then
		result := 'Prerequisite not satisfied.';
end;


--6.
procedure drop_students( v_B# in students.b#%type, v_classid in classes.classid%type, result out varchar2)
is
v_B#_match boolean;
v_classid_match boolean;
v_reg_match boolean;
v_sem_match boolean;
v_prereq_match boolean;
v_tem_dept_code classes.dept_code%type;
v_tem_course# classes.course#%type;
v_count number;
v_size_now number;

cursor c10 is select B# from students;
cursor c11 is select classid from Classes;
cursor c12 is select classid from enrollments where B# = v_B#;
cursor c13 is select classid from Classes where year = 2018 and semester = 'Fall';
cursor c14 is select p.dept_code,p.course# from prerequisites p,Classes c where v_classid = c.classid and c.dept_code = p.pre_dept_code and c.course# = p.pre_course#;
e_invalid_input1 exception;
e_invalid_input2 exception;
e_invalid_input3 exception;
e_invalid_input4 exception;
e_prereq exception;

c10_rec c10%rowtype;
c11_rec c11%rowtype;
c12_rec c12%rowtype;
c13_rec c13%rowtype;
c14_rec c14%rowtype;

begin
	result := '';
	v_B#_match := false;
	v_classid_match := false;
	v_reg_match := false;
	v_sem_match := false;
	v_prereq_match := false;
	v_count := 0;
	for c10_rec in c10 loop
	if  (c10_rec.B# = v_B#) then
			v_B#_match := true;
	end if;
	end loop;
	
	if( v_B#_match = false )then
		raise e_invalid_input1;
	end if;

	for c11_rec in c11 loop
	if  (c11_rec.classid= v_classid) then
			v_classid_match := true;
	end if;
	end loop;

	if( v_classid_match = false )then
		raise e_invalid_input2;
	end if;

	for c12_rec in c12 loop
	v_count := v_count + 1;
	if  (c12_rec.classid= v_classid) then
			v_reg_match := true;
	end if;
	end loop;

	if( v_reg_match = false )then
		raise e_invalid_input3;
	end if;

	for c13_rec in c13 loop
	if  (c13_rec.classid= v_classid) then
			v_sem_match := true;
	end if;
	end loop;

	if( v_sem_match = false )then
		raise e_invalid_input4;
	end if; 

	for c12_rec in c12 loop
		for c14_rec in c14 loop
			select dept_code,course# into v_tem_dept_code,v_tem_course# from classes where classid = c12_rec.classid;
			if (v_tem_dept_code = c14_rec.dept_code) and (v_tem_course# = c14_rec.course#) then
				v_prereq_match := true;
			end if; 
		end loop;
	end loop;

	if( v_prereq_match = true )then
		raise e_prereq;
	end if;

	if (v_classid_match = true) and (v_classid_match = true) and (v_reg_match = true) and (v_sem_match = true) and (v_prereq_match = false) and (v_B#_match = true)
	then 
		select class_size into v_size_now from classes where classid = v_classid;
		if (v_size_now = 1) then
			result := 'The class now has no students.';
		end if;
		delete from enrollments where B# = v_B# and classid = v_classid;
		v_count := v_count - 1;
		if (v_count = 0) then 
			result :='This student is not enrolled in any classes.';
		end if;
		

	end if;
exception
	when e_invalid_input1 then
		result := 'The B# is invalid.';
	when e_invalid_input2 then
		result := 'The classid is invalid.';
	when e_invalid_input3 then
		result :='The student is not enrolled in the class.';
	when e_invalid_input4 then
		result := 'Only enrollment in the current semester can be dropped.';
	when e_prereq then
		result := 'The drop is not permitted because another class the student registered uses it as prerequisite.';
end;

--7
PROCEDURE student_delete( student_id in students.b#%type, result out varchar2)
is
cursor cursor111 is select * from students where b# = student_id;
BEGIN 
	result:='';
	open cursor111;
    if(cursor111%notfound) then
		result := 'Invalid B#';
	else 
	delete from students where b# = student_id;
    result := 'Student :' || student_id || 'has been deleted from table Students';        
	end if;
END;

end;--package end
/
show errors;
