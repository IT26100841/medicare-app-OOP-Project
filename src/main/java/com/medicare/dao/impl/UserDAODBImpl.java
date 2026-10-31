package com.medicare.dao.impl;

import com.medicare.dao.UserDAO;
import com.medicare.model.User;
import com.medicare.util.*;
import java.sql.*;
import java.util.*;

public class UserDAODBImpl implements UserDAO {
  private User map(ResultSet r) throws SQLException {
    User u =
        new User(
            r.getInt("user_id"),
            r.getString("username"),
            r.getString("password"),
            r.getString("role"));
    u.setEmail(r.getString("email"));
    u.setName(u.getUsername());
    return u;
  }

  public User validateUser(String name, String password) {
    User u = getUserByUsername(name);
    if (u == null || !Passwords.verify(password, u.getPassword())) return null;
    if (!Passwords.encoded(u.getPassword())) {
      u.setPassword(Passwords.hash(password));
      if (!updateUser(u)) throw new IllegalStateException("Password upgrade failed");
    }
    return u;
  }

  public User authenticateUser(String n, String p) {
    return validateUser(n, p);
  }

  public User getUserByUsername(String name) {
    return one("SELECT * FROM users WHERE username=?", name);
  }

  public User getUserById(int id) {
    return one("SELECT * FROM users WHERE user_id=?", id);
  }

  private User one(String sql, Object key) {
    try (Connection c = DBConnection.getConnection();
        PreparedStatement s = c.prepareStatement(sql)) {
      s.setObject(1, key);
      try (ResultSet r = s.executeQuery()) {
        return r.next() ? map(r) : null;
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Cannot read user", e);
    }
  }

  public List<User> getAllUsers() {
    try (Connection c = DBConnection.getConnection();
        Statement s = c.createStatement();
        ResultSet r = s.executeQuery("SELECT * FROM users")) {
      List<User> out = new ArrayList<>();
      while (r.next()) out.add(map(r));
      return out;
    } catch (SQLException e) {
      throw new IllegalStateException("Cannot list users", e);
    }
  }

  public boolean addUser(User u) {
    if (!Passwords.encoded(u.getPassword())) u.setPassword(Passwords.hash(u.getPassword()));
    return execute(
        "INSERT INTO users(username,password,role,email) VALUES(?,?,?,?)",
        u.getUsername(),
        u.getPassword(),
        u.getRole(),
        u.getEmail() == null ? "" : u.getEmail());
  }

  public boolean updateUser(User u) {
    if (!Passwords.encoded(u.getPassword())) u.setPassword(Passwords.hash(u.getPassword()));
    return execute(
        "UPDATE users SET password=?,role=?,email=? WHERE username=?",
        u.getPassword(),
        u.getRole(),
        u.getEmail() == null ? "" : u.getEmail(),
        u.getUsername());
  }

  public boolean deleteUser(int id) {
    return execute("DELETE FROM users WHERE user_id=?", id);
  }

  private boolean execute(String sql, Object... values) {
    try (Connection c = DBConnection.getConnection();
        PreparedStatement s = c.prepareStatement(sql)) {
      for (int i = 0; i < values.length; i++) s.setObject(i + 1, values[i]);
      return s.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("User write failed", e);
    }
  }
}
