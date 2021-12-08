import java.io.File;
import java.io.FileNotFoundException;
import java.sql.*;
import java.util.Arrays;
import java.util.Scanner;

import javax.naming.spi.DirStateFactory.Result;

class FinalProject {

    // filename for screts
    // should contain port number, schema name, and mysql password
    private static String SECRETS_FILE = "secrets";

    // java types corresponding to types of data stored in db
    public enum ColumnType {
        STRING,
        INT,
        DOUBLE,
    }

    private static ColumnType[] itemColumnTypes = new ColumnType[]{ColumnType.INT, ColumnType.STRING, ColumnType.STRING, ColumnType.DOUBLE};
    private static ColumnType[] shipmentColumnColumnTypes = new ColumnType[]{ColumnType.INT, ColumnType.INT, ColumnType.INT, ColumnType.STRING};
    private static ColumnType[] purchaseColumnTypes = new ColumnType[]{ColumnType.INT, ColumnType.INT, ColumnType.INT, ColumnType.STRING};

    // database connection instance
    private static Connection conn;

    // active class
    private static String activeClass = "";

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
            case "list-classes":
                listClasses();
        }

    }

    private static ResultSet runQuery(String[] args, String query, Boolean expectResults) {
        
        PreparedStatement stmt = null;
        ResultSet res = null;

        try {
            stmt = conn.prepareStatement(query, ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
            // add arguments to query
            if (args != null) {
                int i = 1;
                for (int j = 1; j < args.length; j++) { // start at 1 to ignore command name
                    stmt.setString(i, args[j]);
                    i++;
                }
            }

            // // actual SQL statement execution
            boolean hasResultSet = stmt.execute();
            System.out.println(hasResultSet);

            if(expectResults)
            {
                if (!hasResultSet) {
                    throw new RuntimeException("Result types specified, but no result set was returned");
                }
                res = stmt.getResultSet();
                res.beforeFirst();
                System.out.println("RESULT SET:" + res);
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
            return;
        }

        String q = "Call createClass(?, ?, ?, ?)";
        runQuery(command, q, false);
    }

    // list classes with the # of students in each
    // list-classes
    private static void listClasses(){
        String q = "SELECT course_number, count(student_id) as students FROM Class NATURAL JOIN Enrolled GROUP BY course_number";
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
    // 
    private static void selectClass(String[] command){



        // select section of class in most recent term; if there are multiple
        // sections, fail
        if(command.length == 2){

        } // select only section of class in given term; if there are multiple, fail
        else if(command.length == 3){

        } // select specified section
        else if(command.length == 4){

        }
    }

}