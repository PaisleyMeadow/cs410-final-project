import java.io.File;
import java.io.FileNotFoundException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;

class FinalProject {

    // filename for screts
    // should contain port number, schema name, and mysql password
    private static String SECRETS_FILE = "secrets";

    // active class
    public static class ActiveClass{
        // static String name = null;
        // static int id = -1;

        // for testing:
        static String name = "im773";
        static int id = 87;
    }

    // database connection instance
    private static Connection conn;

    /**
     * Connect to the database
     *
     * @return database connection
     */
    private static Connection makeConnection() {
        // load secrets from file
        Scanner sc = null;
        try {
            sc = new Scanner(new File(SECRETS_FILE));
        } catch (FileNotFoundException e) {
            System.out.println("Couldn't load secrets file from '" + SECRETS_FILE + "'");
            System.exit(1);
        }
        String[] secrets = new String[3];
        for (int i = 0; i < secrets.length; i++) {
            secrets[i] = sc.nextLine().strip();
        }

        // attempt to connect to database
        Connection conn = null;
        try {
            System.out.println("Attempting to connect to DB...");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:" + secrets[0] + "/" + secrets[1] +
                    "?verifyServerCertificate=false&useSSL=true&serverTimezone=UTC", "msandbox", secrets[2]);
            System.out.println("Database " + secrets[1] + " connection succeeded!");
        } catch (SQLException ex) {
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
            System.exit(1);
        }

        return conn;
    }

    public static void main(String[] args){

        // connect to the database
        try {
            // workaround for some broken Java implementations
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ReflectiveOperationException e) {
            System.out.println("Error loading JDBC Driver! Outputting stack trace");
            e.printStackTrace();
            System.exit(1);
        }
        System.out.println();
        System.out.println("JDBC driver loaded");
        conn = makeConnection();
        assert conn != null;
        ////////

        String s;
        Scanner scanner = new Scanner(System.in);
        System.out.println("Please enter a command...");

        while((s = scanner.nextLine()).length() > 0) {
            parseCommand(s);
        }

            // System.exit(1);
    }

    private static void parseCommand(String s) {

        String[] command = s.split(" ");

        switch(command[0]){
            case "new-class":
                addNewClass(command);
                break;
            case "list-classes":
                listClasses();
                break;
            case "select-class":
                selectClass(command);
                break;
            case "show-class":
                showClass();
                break;
            case "show-categories":
                showCategories();
                break;
            case "add-category":
                addCategory(command);
                break;
            case "show-assignment":
                showAssignment();
                break;
            case "show-students":
                showStudents(command);
                break;
            case "grade":
                assignGrade(command);
                break;
            case "q":
                System.exit(0);
            default:
                System.out.println("Failed to understand command.");
                break;
        }

    }

    private static ResultSet runQuery(String[] args, String query, Boolean expectResults) {
        
        PreparedStatement stmt = null;
        ResultSet res = null;

        try {
            stmt = conn.prepareStatement(query, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
            // add arguments to query
            if (args != null) {
                int i = 1;
                for (int j = 1; j < args.length; j++) { // start at 1 to ignore command name
                    stmt.setString(i, args[j]);
                    i++;
                }
            }

            // actual SQL statement execution
            boolean hasResultSet = stmt.execute();

            if(expectResults)
            {
                if (!hasResultSet) {
                    throw new RuntimeException("Result types specified, but no result set was returned");
                }
                res = stmt.getResultSet();
                res.beforeFirst();

                return res;
            }

            return null;
    
        }catch (SQLException ex) {
            System.err.println("Unable to execute query.");
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
        } finally {
            // if (res != null) {
            //     try {
            //         res.close();
            //     } catch (SQLException ignored) {
            //     }
            // }
            // if (stmt != null) {
            //     try {
            //         stmt.close();
            //     } catch (SQLException ignored) {
            //     }
            // }
        }

        return res;
    }

    // add new class
    // new-class CS410 Sp20 1 "Databases"
    private static void addNewClass(String[] command) {
        if(command.length < 5){
            System.out.println(
                "Missing one or more parameters. Format is: new-class <class number> <term> <section> \"<description>\"");
        }
        else{
            String q = "Call createClass(?, ?, ?, ?)";
            runQuery(command, q, false);
        }
    }

    // list classes with the # of students in each
    // list-classes
    private static void listClasses(){
        String q = "SELECT course_number, count(student_id) as students FROM Class LEFT JOIN Enrolled ON Class.course_id = Enrolled.course_id GROUP BY course_number";
        ResultSet res = runQuery(null, q, true);

        StringBuilder output = new StringBuilder();
        output.append("Class | # Students\n");
        try{
            while(res.next()){
                output.append(res.getString("course_number") + "  |  ");
                output.append(res.getInt("students") + "\n");
            }
        }
        catch(SQLException ex){
            System.err.println("Unable to print result set.");
            System.err.println("SQLException: " + ex.getMessage());
        }

        System.out.println(output);
    }

    // set the active class
    // select-class <class number> : selects only section of that class in the most recent term;
    // if there is multiple section that match this criteria, it fails
    //
    // select-class <class number> <term> selects the only section of class number in given term
    //
    // select-class <class number> <term> <section> selects specified section
    // 
    // ex: select-class vc567 xp8857
    private static void selectClass(String[] command){
    
        // get the class(es)
        String q = "Call selectClass(?, ?, ?)";

        // need at least one parameter 
        if(command.length < 2){
            System.out.println(
                "No parameters provided. Format: select-classs <class number> [<term>] [<section>]"
                );
            return;
        }

        // some array manipulation because I'm lazy...
        // (gotta add nulls to parameters)
        ArrayList<String> comList = new ArrayList<String>(Arrays.asList(command));
        if(command.length == 2){
            comList.add((String)null);
            comList.add((String)null);
        }
        if(command.length == 3){
            comList.add(null);
        }

        String[] all_args = (String[]) comList.toArray(new String[comList.size()]);

        ResultSet res = runQuery(all_args, q, true);
        
        // get number of rows returned
        int numRows = 0;
        try {
            if (res.last()) {
                numRows = res.getRow();
                // Move to beginning
                res.beforeFirst();
            }
        } catch (SQLException ex) {
            System.err.println("Unable to query class.");
            System.err.println("SQLException: " + ex.getMessage());
        }
        
        // if there are multiple classes that match the parameters, fail
        if(numRows > 1){
            System.out.println("Unable to select class; more than one class was returned.");
        }
        else if(numRows == 0){
            System.out.println("No class found. Active class not set.");
        } 

        try {

            if(res.first()){
                FinalProject.ActiveClass.id = res.getInt(1);
                FinalProject.ActiveClass.name = res.getString("course_number");

                System.out.println("Active class set to: " + FinalProject.ActiveClass.name);

                
        }
        } catch (SQLException ex) {
            System.err.println("Unable to set active class.");
            System.err.println("SQLException: " + ex.getMessage());
        }
    }

    private static void showClass(){
        if(FinalProject.ActiveClass.id != -1){
            System.out.println("Active class: " + FinalProject.ActiveClass.name);
        }
        else{
            System.out.println("No active class set.");
        }
    }

    /**
     * show-students <substring> OR show-students
     * show either all students for the currently selected class
     * or show all students with <substring> in their name or username(case-insensitive)
     * If a class is not selected, don't run a query and tell the user to select a class.
     * @param command - either has substring, or is len=1 and tells us to show all students
     * @author - Paisley Meadow, Teddy Ramey
     */
    private static void showStudents(String[] command){
        //declare variables
        ResultSet res;
        StringBuilder output;
        String q;

        //Check if an active class exists. If not tell the user and return
        if(FinalProject.ActiveClass.id == -1){
            System.out.println("No active class set.");
            return;
        }

        //Case where user wants all students for the active class
        if(command.length < 2){
            q = "Call selectAllStudents(" + FinalProject.ActiveClass.id + ")";
        }
        //Case where we compare student name/username against a string
        else {
            // add % around input string
            String s = "%" + command[1] + "%";
            command[1] = s;

            q = "Call selectStudents(?, " + FinalProject.ActiveClass.id + ")";
        }

        //Call the correct query (based on the above if/else)
        res = runQuery(command, q, true);
        output = new StringBuilder();

        //iterate through the result set, printing out each pair of student/username
        try{
            while(res.next()){
                output.append(res.getString("student_name") + "  |  ");
                output.append(res.getString("username") + "\n");
            }

            System.out.print(output);
        }
        catch(SQLException ex){
            System.err.println("Unable to print result set.");
            System.err.println("SQLException: " + ex.getMessage());
        }
    }

    /**
     * grade <assignmentname> <username> <grade>
     * assign the grade gradefor student
     *   with user name "username" for assignment "assignmentname". If the student already has a
     *   grade for that assignment, replace it. If the number of points exceeds the number of
     *  points configured for the assignment, print a warning (showing the number of points
     *  configured)
     * @param command
     */
    private static void assignGrade(String[] command){

    if(command.length < 4){
        System.out.println("Missing parameters. Format: grade <student username> <assignment name> <grade>");
        return;
    }
    else if(command.length > 4){
        System.out.println("Too many parameters. Format: grade <student username> <assignment name> <grade>");
        return;
    }

    if(FinalProject.ActiveClass.id == -1){
        System.out.println("No active class set.");
        return;
    }

    String q = "Call assignGrade(?, ?, ?, " + FinalProject.ActiveClass.id + ", @result)";

    ResultSet res = runQuery(command, q, true);

    try{
        while(res.next()){
            int returnVal = res.getInt("result");
            if(returnVal > 0){
                System.out.println("Warning: grade exceeds assignment point value (" + returnVal + "). ");
            }
            else if(returnVal == -1){
                System.out.println("Student is not enrolled in active class.");
                return;
            }
            else if(returnVal == -2){
                System.out.println("Assignment not found for active class.");
                return;
            }
        }

        System.out.println("Grade assigned.");
    }
    catch(SQLException ex){
        System.err.println("Unable to print result set.");
        System.err.println("SQLException: " + ex.getMessage());
    }

    }

    /** 
     * show-categories
     * Show the categories and their respective weights for the currently selected class.
     * If a class is not selected, don't run a query and tell the user to select a class.
     * @author - Teddy Ramey
     */
    private static void showCategories() {
        //Check for an active class
        if(FinalProject.ActiveClass.id == -1){
            System.out.println("No active class set.");
            return;
        }

        //Declare variables
        String q = "SELECT category_name, weight FROM Category WHERE course_id = " + FinalProject.ActiveClass.id + "ORDER BY weight DESC";
        ResultSet res = runQuery(null, q, true);
        StringBuilder output = new StringBuilder();

        //iterate through the result set, printing out each category name/weight
        try{
            while(res.next()){
                output.append(res.getString("category_name") + "  |  ");
                output.append(res.getDouble("weight") + "\n");
            }

            System.out.print(output);
        }
        catch(SQLException ex){
            System.err.println("Unable to print result set.");
            System.err.println("SQLException: " + ex.getMessage());
        }
    }

    /**  
     * add-category <name> <weight>
     * Add a category of name <name> and weight <weight> to the currently selected class.
     * If a class is not selected, don't run a query and tell the user to select a class.
     * @param command - array of strings representing the command, name, and weight
     * @author - Teddy Ramey
     */
    private static void addCategory(String[] command) {
        //Check for an active class
        if(FinalProject.ActiveClass.id == -1){
            System.out.println("No active class set.");
            return;
        }

        if(command.length < 3) {
            System.out.println("Missing one or more parameters. Format is: new-category <name> <weight>");
            return;
        }

        //Declare variables
        String q = "Call createCategory(?, ?, " + FinalProject.ActiveClass.id + ")";
        runQuery(command, q, false);
    }

    /**
     * show-assignment
     * List the assignments and their points for the currently selected class grouped by category.
     * If a class is not selected, don't run a query and tell the user to select a class.
     * @author - Teddy Ramey
     */
    private static void showAssignment() {
         //Check for an active class
         if(FinalProject.ActiveClass.id == -1){
            System.out.println("No active class set.");
            return;
        }       

        String q = "SELECT category_name, assignment_name, points FROM Category INNER JOIN Assignment ON Category.category_id = Assignment.category_id";
        q += "WHERE course_id = " + FinalProject.ActiveClass.id + "ORDER BY category_name ASC, assignment_name ASC";
        ResultSet res = runQuery(null, q, true);
        StringBuilder output = new StringBuilder();

        //iterate through the result set, printing out each category name/weight
        try{
            output.append("Category  |  ");
            output.append("Assignment  |  ");
            output.append("Points\n");
            while(res.next()){
                output.append(res.getString("category_name") + "  |  ");
                output.append(res.getString("assignment_name") + "  |  ");
                output.append(res.getInt("points") + "\n");
            }

            System.out.print(output);
        }
        catch(SQLException ex){
            System.err.println("Unable to print result set.");
            System.err.println("SQLException: " + ex.getMessage());
        }        
    }

    /**
     * add-assignment <name> <Category> <Description> <points> 
     * Add a category of a speciified name, description, and point value to the category selected.
     * If a class is not selected, don't run a query and tell the user to select a class.
     * @param command - array of strings holding assignmnet specifications detailed above
     * @author - Teddy Ramey
     */
    private static void addAssignment(String[] command) {

    }

    /**
     * add-student <username> <studentid> <Last> <First> OR add-student <username>
     * Add a student with specified metadata to our Student table and enroll them in the selected class.
     * OR enroll the student specified by <username> to the currently selected class.
     * @param command - array of strings holding student specifications
     * @author - Teddy Ramey
     */
    private static void addStudent(String[] command) {

    }
}
