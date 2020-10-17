/*
 * PROJECT: PUBLIC LIBRARY CRUD.
 * LUIS J. BRAVO ZÚÑIGA.
 * MANAGER USER CLASS.
 */
package accessData;

import exception.MyException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import oracle.jdbc.OracleTypes;

public class ManagerUser {

    private static ManagerUser INSTANCE = null;
    private static final String LOGIN = "{?=call f_check_login(?,?)}",
            UPDATE_USER = "{call p_update_user(?,?)}";

    private ManagerUser() {
    }

    public static ManagerUser getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new ManagerUser();
        }
        return INSTANCE;
    }

    public boolean check(String username, String password) {
        CallableStatement pstmt = null;
        Connection conexion = ManagerConexionDB.getInstance().connect();
        short result = -1;
        try {
            pstmt = conexion.prepareCall(LOGIN);
            pstmt.clearParameters();
            pstmt.registerOutParameter(1, OracleTypes.NUMBER);
            pstmt.setString(2, username);
            pstmt.setString(3, password);
            if (pstmt.execute()) {
                throw new MyException(MyException.GET_ERROR_OPERATION());
            } else {
                result = (short) pstmt.getBigDecimal(1).intValue();
            }
        } catch (SQLException | MyException ex) {
            MyException.SHOW_ERROR(ex.getMessage());
        } finally {
            try {
                if (pstmt != null) {
                    pstmt.close();
                }
                ManagerConexionDB.getInstance().disconnect();
            } catch (SQLException ex) {
                MyException.SHOW_ERROR(ex.getMessage());
            }
        }
        return result == 1;
    }

    public boolean update(String username, String password) {
        boolean result = false;
        PreparedStatement pstmt = null;
        Connection conexion = ManagerConexionDB.getInstance().connect();
        try {
            pstmt = conexion.prepareStatement(UPDATE_USER);
            pstmt.clearParameters();
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            if (pstmt.execute()) {
                throw new MyException(MyException.GET_ERROR_OPERATION());
            } else {
                result = true;
            }
        } catch (SQLException | MyException ex) {
            MyException.SHOW_ERROR(ex.getMessage());
        } finally {
            try {
                if (pstmt != null) {
                    pstmt.close();
                }

                ManagerConexionDB.getInstance().disconnect();
            } catch (SQLException ex) {
                MyException.SHOW_ERROR(ex.getMessage());
            }
        }
        return result;
    }

} //END CLASS
