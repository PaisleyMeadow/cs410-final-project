import java.io.File;
import java.io.FileNotFoundException;
import java.sql.*;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Scanner;

import javax.naming.spi.DirStateFactory.Result;

class FinalProject {

    // filename for screts
    // should contain port number, schema name, and mysql password
    private static String SECRETS_FILE = "secrets";

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

    /**
     * Run a query on the database
     *
     * @param query       SQL query string, including '?' for arguments
     * @param args        arguments for string
     * @param columnTypes data types of each respective result set column
     */
    private static void runQuery(String query, String[] args) {
        PreparedStatement stmt = null;
        ResultSet rs = null;

        // prepare statement for execution
        try {
            stmt = conn.prepareStatement(query);
            // add arguments to query
            if (args != null) {
                int i = 1;
                for (String argument : args) {
                    stmt.setString(i, argument);
                    i++;
                }
            }

            // actual SQL statement execution
            boolean hasResultSet = stmt.execute();

            // get the results
            // if (columnTypes != null) {
                if (!hasResultSet) {
                    throw new RuntimeException("Result types specified, but not result set was returned");
                }
            //     rs = stmt.getResultSet();
            //     rs.beforeFirst();
            //     System.out.println("RESULT SET:");
            //     while (rs.next()) {
            //         StringBuilder output = new StringBuilder();
            //         int i = 1;
            //         for (ColumnType columnType : columnTypes) {
            //             switch (columnType) {
            //                 case STRING:
            //                     output.append(rs.getString(i));
            //                     break;
            //                 case INT:
            //                     output.append(rs.getInt(i));
            //                     break;
            //                 case DOUBLE:
            //                     output.append(rs.getDouble(i));
            //                     break;
            //             }
            //             if (i < columnTypes.length) {
            //                 output.append(":");
            //             }
            //             i++;
            //         }
            //         System.out.println(output);
            //     }
            // }
            System.out.println(stmt.getResultSet());
        } catch (SQLException ex) {
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException ignored) {
                }
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException ignored) {
                }
            }
        }
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
            System.out.println("String was " + s);
            parseCommand(s);
        }

            // System.exit(1);
    }

    private static void parseCommand(String s) {

        String[] command = s.split(" ");

        switch(command[0]){
            case "new-class":
                addNewClass(command);
        }

    }

    // new-class CS410 Sp20 1 "Databases"
    private static void addNewClass(String[] command) {
        if(command.length < 5){
            System.out.println(
                "Missing one or more parameters. Format is: new-class <class number> <term> <section> \"<description>\"");
            return;
        }

        String q = "Call createClass(?, ?, ?, ?)";
        runQuery(command, q);
    }

    private static void runQuery(String[] args, String query) {
        
        PreparedStatement stmt = null;
        ResultSet res = null;

        try {
            stmt = conn.prepareStatement(query);
            // add arguments to query
            if (args != null) {
                int i = 1;
                for (int j = 1; j < args.length; j++) { // start at 1 to ignore command name
                    stmt.setString(i, args[j]);
                    System.out.println("query: " + stmt);
                    i++;
                }
            }

            // // actual SQL statement execution
            boolean hasResultSet = stmt.execute();
            System.out.println(hasResultSet);

        }catch (SQLException ex) {
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
        } finally {
            if (res != null) {
                try {
                    res.close();
                } catch (SQLException ignored) {
                }
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

}