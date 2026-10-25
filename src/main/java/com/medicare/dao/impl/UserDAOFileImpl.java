package com.medicare.dao.impl;

import com.medicare.dao.UserDAO;
import com.medicare.model.User;

import java.util.ArrayList;
import java.util.List;

public class UserDAOFileImpl implements UserDAO {

    @Override
    public User validateUser(String username, String password) {
        if ("admin".equals(username) && "admin123".equals(password)) {
            return new User("admin", "admin123", "ADMIN");
        } else if ("dr_perera".equals(username) && "doc123".equals(password)) {
            return new User("dr_perera", "doc123", "DOCTOR");
        }
        return null;
    }

    @Override
    public User authenticateUser(String username, String password) {
        return validateUser(username, password);
    }

    @Override
    public User getUserByUsername(String username) {
        return null;
    }

    @Override
    public User getUserById(int id) {
        return null;
    }

    @Override
    public boolean addUser(User user) {
        return true;
    }

    @Override
    public boolean updateUser(User user) {
        return true;
    }

    @Override
    public boolean deleteUser(int id) {
        return true;
    }

    @Override
    public List<User> getAllUsers() {
        return new ArrayList<>();
    }
}