package com.medicare.dao;

import com.medicare.model.User;
import java.util.List;

public interface UserDAO {
    User validateUser(String username, String password);
    User authenticateUser(String username, String password);
    User getUserByUsername(String username);
    User getUserById(int id);
    boolean addUser(User user);
    boolean updateUser(User user);
    boolean deleteUser(int id);
    List<User> getAllUsers();
}