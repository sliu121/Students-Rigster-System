import java.sql.*;

import oracle.jdbc.*;
import oracle.jdbc.pool.OracleDataSource;

import javax.swing.table.TableRowSorter;
import javax.xml.stream.FactoryConfigurationError;
import java.io.*;


public class main {
    private static String GetInput() throws IOException {
        BufferedReader input_buffer;
        input_buffer = new BufferedReader(new InputStreamReader(System.in));
        String input_string;
        input_string = input_buffer.readLine();
        return input_string;
    }

    /***
     * Home Page
     */
    private static void WelcomeInterface(){
        System.out.println(" \n=======================Welcome to system=======================\n");

        System.out.println(" 1. Show tables in Database");
        System.out.println(" 2. Who is Ta?");
        System.out.println(" 3. Check the prerequisite courses");
        System.out.println(" 4. Enrollment");
        System.out.println(" 5. Drop Class");
        System.out.println(" 6. Delete Student");
        System.out.println(" \n--------------------------------------------------");
        System.out.println(" 0.Exit");

        System.out.println("Select your operation: ");
    }

    /**
     * 2 parts of ShowTable, Interface and Process
     */
    private static void ShowTableInterface(){
        System.out.println(" \n=======================Show table info=======================\n");

        System.out.println(" 1. Students");
        System.out.println(" 2. Classes");
        System.out.println(" 3. Courses");
        System.out.println(" 4. TAs");
        System.out.println(" 5. Enrollments");
        System.out.println(" 6. Prerequisite courses ");
        System.out.println(" 7. Logs");
        System.out.println(" \n--------------------------------------------------");
        System.out.println(" \n--------------------------------------------------");

        System.out.println(" 0.Back");

    }
    private static boolean ShowEachTable(String input_string_1,boolean choose_first,Connection conn) throws SQLException {
        if(input_string_1.equals("1"))
        {
            /**Show students_table**/
            CallableStatement cs = conn.prepareCall("begin proj2.show_students(?); end;");
            ResultSet resultSet;
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.execute();
            resultSet = (ResultSet)cs.getObject(1);
            while (resultSet.next()){
                System.out.println( resultSet.getString(1) + "\t" +
                        resultSet.getString(2) + "\t" + resultSet.getString(3) +
                        resultSet.getString(4) +
                        "\t" + resultSet.getDouble(5) + "\t" +
                        resultSet.getString(6));

            }

            cs.close();
        }else if(input_string_1.equals("2")){
            /**Classes table shows**/

            CallableStatement cs = conn.prepareCall("begin proj2.show_classes(?); end;");
            ResultSet resultSet;
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.execute();
            resultSet = (ResultSet)cs.getObject(1);
            while (resultSet.next()){
                System.out.println( resultSet.getString(1) + "\t" +
                        resultSet.getString(2) + "\t" + resultSet.getString(3) +
                        resultSet.getString(4) +
                        "\t" + resultSet.getDouble(5) + "\t" +
                        resultSet.getString(6)+"\t" +
                        resultSet.getString(7) + "\t" +
                        resultSet.getString(8)+"\t" +
                        resultSet.getString(9)+"\t" +
                        resultSet.getString(10));

            }

            cs.close();
        }
        else if(input_string_1.equals("3")){
            /**Courses table shows**/

            CallableStatement cs = conn.prepareCall("begin proj2.show_courses(?); end;");
            ResultSet resultSet;
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.execute();
            resultSet = (ResultSet)cs.getObject(1);
            while (resultSet.next()){
                System.out.println( resultSet.getString(1) + "\t" +
                        resultSet.getString(2) + "\t" +
                        resultSet.getString(3));

            }

            cs.close();
        }
        else if(input_string_1.equals("4")){
            /**Showing Tas table**/
            CallableStatement cs = conn.prepareCall("begin proj2.show_tas(?); end;");
            ResultSet resultSet;
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            //System.out.println("Before execute");
            cs.execute();
            //System.out.println("After Execute");
            resultSet = (ResultSet)cs.getObject(1);
            while (resultSet.next()){
                System.out.println( resultSet.getString(1) + "\t" +
                        resultSet.getString(2) + "\t"
                        + resultSet.getString(3));

            }

            cs.close();
        }
        else if(input_string_1.equals("5")){
            /**Enrollment table shows**/

            CallableStatement cs = conn.prepareCall("begin proj2.show_enrollments(?); end;");
            ResultSet resultSet;
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.execute();
            resultSet = (ResultSet)cs.getObject(1);
            while (resultSet.next()){
                System.out.println( resultSet.getString(1) + "\t" +
                        resultSet.getString(2) + "\t" +
                        resultSet.getString(3) );

            }

            cs.close();
        }
        else if(input_string_1.equals("6")){
            /**Prerequisites table shows**/

            CallableStatement cs = conn.prepareCall("begin proj2.show_prerequisites(?); end;");
            ResultSet resultSet;
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.execute();
            resultSet = (ResultSet)cs.getObject(1);
            while (resultSet.next()){
                System.out.println( resultSet.getString(1) + "\t" +
                        resultSet.getString(2) + "\t" + resultSet.getString(3) +
                        resultSet.getString(4));

            }

            cs.close();
        }else if(input_string_1.equals("7")){
            /**Showing Tas table**/
            CallableStatement cs = conn.prepareCall("begin proj2.show_logs(?); end;");
            ResultSet resultSet;
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.execute();
            resultSet = (ResultSet)cs.getObject(1);
            while (resultSet.next()){
                System.out.println( resultSet.getString(1) + "\t" +
                        resultSet.getString(2) + "\t"
                        + resultSet.getString(3) +
                        resultSet.getString(4) +
                        "\t" + resultSet.getString(5) + "\t" +
                        resultSet.getString(6));

            }

            cs.close();
        }

        else if (input_string_1.equals("0"))
        {
            choose_first = false;
        }
        return choose_first;

    }

    /**
     * 2 parts of FindTa, Interface and Process
     */
    private static void FindTaInterface(){
        System.out.println("\n--------------------------------------------------");
        System.out.println("Input classid you want to check: (input 0 to Back)\n--------------------------------------------------");
    }
    private static CallableStatement FindTaProcess(Connection conn,String cid) throws SQLException {
        CallableStatement cs = conn.prepareCall("begin proj2.find_tas(?,?); end;");
        cs.setString(1,cid);
        cs.registerOutParameter(2, Types.VARCHAR);
        cs.execute();
        return cs;
    }

    private static void Pre_RequiredInterface(boolean Course){

        if(Course){
            System.out.println("Input course_# you want to check: (input 0 to back)\n--------------------------------------------------");
        }else {
            System.out.println("\n--------------------------------------------------");
            System.out.println("Input dept_code you want to check: (input 0 to back)\n--------------------------------------------------");
        }
    }
    private static CallableStatement Pre_RequiredProcess(Connection conn,String dept_code,int course_number) throws SQLException {
        CallableStatement cs = conn.prepareCall("begin proj2.find_precourses(?,?,?,?); end;");
        cs.setString(1,dept_code);
        cs.setInt(2,course_number);
        cs.registerOutParameter(3,Types.VARCHAR);
        cs.registerOutParameter(4,Types.VARCHAR);
        cs.execute();
        return cs;
    }

    private static void EnrollmentInterface(boolean second){
        if(!second){
            System.out.println("\n--------------------------------------------------");
            System.out.println("Input b#: (input 0 to back)\n--------------------------------------------------");
        }else{
            System.out.println("Input classid you want to enrollin: (input 0 to back)\n--------------------------------------------------");
        }

    }
    private static CallableStatement EnrollmentProcess(Connection conn,String sid,String classid) throws SQLException {
        CallableStatement cs = conn.prepareCall("begin proj2.add_enroll(?,?,?); end;");
        cs.setString(1,sid);
        cs.setString(2,classid);
        cs.registerOutParameter(3,Types.VARCHAR);
        cs.execute();
        return cs;
    }

    private static void DropClassInterface(boolean second){
        if(!second){
            System.out.println("\n--------------------------------------------------");
            System.out.println("Input b#: (input 0 to back)\n--------------------------------------------------");
        }else{
            System.out.println("Input classid you want to drop: (input 0 to back)\n--------------------------------------------------");
        }
    }
    private static CallableStatement DropClassProcess(Connection conn, String sid,String classid) throws SQLException {
        CallableStatement cs = conn.prepareCall("begin proj2.drop_students(?,?,?); end;");
        cs.setString(1,sid);
        cs.setString(2,classid);
        cs.registerOutParameter(3,Types.VARCHAR);
        cs.execute();
        return cs;
    }

    private static void DeleteStudentsInterface(){
        System.out.println("\n--------------------------------------------------");
        System.out.println("Input b#: (input 0 to back)\n--------------------------------------------------");
    }
    private static CallableStatement DeleteStudentProcess(Connection conn,String sid) throws SQLException {
        CallableStatement cs = conn.prepareCall("begin proj2.student_delete(?,?); end;");
        cs.setString(1,sid);
        cs.registerOutParameter(2,Types.VARCHAR);
        cs.execute();
        return cs;
    }

    private static boolean QuitSystem() throws IOException {
        System.out.println("Quit?(y/n): ");

        String input_string = GetInput();

        /**if user input y**/
        if(input_string.equals("y"))return true;

        return false;
    }

    public static void main (String args []) throws SQLException {
        try
        {

            Connection conn = BuildConnection();
            boolean sys_working;
            sys_working = true;
            while(sys_working )
            {
                WelcomeInterface();
                String input_string = GetInput();

                // now make a submenu
                // if user choose '1'
                if(input_string.equals("1"))
                {

                    boolean choose_first = true;
                    while(choose_first)
                    {
                        ShowTableInterface();
                        String input_string_1 = GetInput();
                        /**Now we check the input value to show the tables*/
                        choose_first= ShowEachTable(input_string_1,choose_first,conn);
                    }

                }
                if(input_string.equals("2"))
                {
                    /**Now we are going to find Ta**/
                    boolean chose_sec = true;
                    while(chose_sec){
                        FindTaInterface();
                        String cid = GetInput();
                        if(cid.equals("0")){
                            chose_sec = false;
                        }else{
                            CallableStatement cs = FindTaProcess(conn,cid);
                            System.out.println(cs.getString(2));
                            cs.close();
                        }
                    }
                }

                if(input_string.equals("3")){
                    /**Now we are going to check pre_required course**/
                    boolean chose_third = true;

                    while(chose_third){

                        Pre_RequiredInterface(false);
                        String dept_code = GetInput();

                        if (dept_code.equals("0")){

                            chose_third = false;

                        }else{

                            Pre_RequiredInterface(true);
                            String course_no = GetInput();

                            if(course_no.equals("0")){

                                chose_third = false;

                            }else{
                                int course_number = Integer.parseInt(course_no);

                                CallableStatement cs = Pre_RequiredProcess(conn,dept_code,course_number);

                                System.out.println(cs.getString(3));
                                System.out.println(cs.getString(4));

                                cs.close();
                            }
                        }

                    }
                }

                if(input_string.equals("4")){
                    /**Now we are going to enroll**/
                    boolean chose_forth = true;
                    while(chose_forth){

                        EnrollmentInterface(false);
                        String sid = GetInput();

                        if(sid.equals("0")){
                            chose_forth = false;
                        }else{
                            EnrollmentInterface(true);
                            String classid = GetInput();
                            if(classid.equals("0")){
                                chose_forth = false;
                            }else{
                                CallableStatement cs = EnrollmentProcess(conn,sid,classid);
                                System.out.println(cs.getString(3));
                                cs.close();
                            }
                        }

                    }
                }

                if(input_string.equals("5")){
                    boolean chose_fifth = true;
                    while (chose_fifth)
                    {
                        DropClassInterface(false);
                        String sid = GetInput();
                        if(sid.equals("0")){
                            chose_fifth = false;
                        }else{
                            DropClassInterface(true);
                            String classid = GetInput();
                            if(classid.equals("0")){
                                chose_fifth = false;
                            }else{
                                CallableStatement cs = DropClassProcess(conn,sid,classid);
                                System.out.println(cs.getString(3));
                                cs.close();
                            }


                        }
                    }

                }
                if(input_string.equals("6")){
                    boolean chose_sixth = true;
                    while (chose_sixth){
                        DeleteStudentsInterface();
                        String sid = GetInput();
                        if(sid.equals("0")){
                            chose_sixth = false;
                        }
                        else {
                            CallableStatement cs = DeleteStudentProcess(conn,sid);
                            System.out.println(cs.getString(2));
                            cs.close();
                        }
                    }
                }


                // now we want to exit sys
                if (input_string.equals("0")){
                    if(QuitSystem()){
                        sys_working = false;
                        conn.close();
                    }

                }

            }
        }
        catch (SQLException ex) { System.out.println ("\n*** SQLException caught ***\n" + ex.getMessage());}
        catch (Exception e) {System.out.println ("\n*** other Exception caught ***\n"+ e.getMessage());}
    }

    public static Connection BuildConnection() throws SQLException, IOException {
        Console console = System.console();
        System.out.println("Welcome to use our SRS System!");
        System.out.println("--------------------------------------------------");
        System.out.println("Enter your Id please: ");
        BufferedReader id_buffer = new BufferedReader(new InputStreamReader(System.in));
        String id_String;
        id_String = id_buffer.readLine();

        System.out.println("--------------------------------------------------");

        console.printf("Please enter your password: \n");
        char[] passwordChars = console.readPassword();
        String passwordString = new String(passwordChars);

        OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
//        ds.setURL();
        Connection conn = ds.getConnection(id_String, passwordString);

        return conn;
    }

}
