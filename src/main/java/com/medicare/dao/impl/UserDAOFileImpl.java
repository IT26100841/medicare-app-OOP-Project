package com.medicare.dao.impl;

import com.medicare.dao.UserDAO;
import com.medicare.model.User;
import java.util.*;

public class UserDAOFileImpl extends AbstractFileDAO<User> implements UserDAO {
  public UserDAOFileImpl() {
    super("users.txt", User.class, "id", "username", "password", "role", "name", "email");
  }

  public User validateUser(String name, String password) {
    User u = getUserByUsername(name);
    return u != null && com.medicare.util.Passwords.verify(password, u.getPassword()) ? u : null;
  }

  public User authenticateUser(String n, String p) {
    return validateUser(n, p);
  }

  public User getUserByUsername(String name) {
    return find(u -> u.getUsername().equalsIgnoreCase(name));
  }

  public User getUserById(int id) {
    return find(u -> u.getId() == id);
  }

  public List<User> getAllUsers() {
    return readAll();
  }

  public boolean addUser(User u) {
    synchronized (LOCK) {
      if (getUserByUsername(u.getUsername()) != null) return false;
      if (!com.medicare.util.Passwords.encoded(u.getPassword()))
        u.setPassword(com.medicare.util.Passwords.hash(u.getPassword()));
      u.setId(readAll().stream().mapToInt(User::getId).max().orElse(0) + 1);
      return insert(u);
    }
  }

  public boolean updateUser(User u) {
    if (!com.medicare.util.Passwords.encoded(u.getPassword()))
      u.setPassword(com.medicare.util.Passwords.hash(u.getPassword()));
    return replace(u, x -> x.getUsername().equalsIgnoreCase(u.getUsername()));
  }

  public boolean deleteUser(int id) {
    return remove(u -> u.getId() == id);
  }
}
