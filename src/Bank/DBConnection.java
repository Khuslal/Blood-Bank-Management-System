package Bank;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    // Corrected the URL protocol
    private static final String URL = "jdbc:mysql://localhost:3306/blood_bank?useSSL=false&allowPublicKeyRetrieval=true";

    private static final String USER = "root";
    private static final String PASS = "password";

    public static Connection connect() {
        try {
            // Corrected the Driver class path
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            Connection con = DriverManager.getConnection(URL, USER, PASS);
            System.out.println("✅ Database connected successfully");
            return con;
        } catch (Exception e) {
            System.out.println("❌ Database Connection Error:");
            e.printStackTrace();
            return null;
        }
    }
}
