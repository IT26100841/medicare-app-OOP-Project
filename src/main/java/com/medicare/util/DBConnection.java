package com.medicare.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
  private static final String URL =
      System.getProperty(
          "medicare.db.url",
          "jdbc:mysql://localhost:3306/medicare_db?useSSL=false&allowPublicKeyRetrieval=true");
  private static final String USER =
      System.getProperty("medicare.db.user", "root"); // ඔයාගේ MySQL Username එක
  private static final String PASSWORD =
      System.getProperty(
          "medicare.db.password", ""); // ඔයාගේ MySQL Password එක (තිබේ නම් ඇතුළත් කරන්න)

  static {
    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
    }
  }

  public static Connection getConnection() throws SQLException {
    return DriverManager.getConnection(URL, USER, PASSWORD);
  }
}
