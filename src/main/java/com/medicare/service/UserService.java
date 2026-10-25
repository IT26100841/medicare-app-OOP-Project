package com.medicare.service;

import com.medicare.factory.DAOFactory;
import com.medicare.model.User;

import java.util.List;

public class UserService {

    public User authenticate(String username, String password) {
        return DAOFactory.getUserDAO().authenticateUser(username, password);
    }

    public boolean addUser(User user) {
        return DAOFactory.getUserDAO().addUser(user);
    }

    public List<User> getAllUsers() {
        return DAOFactory.getUserDAO().getAllUsers();
    }

    public User getUserById(int id) {
        return DAOFactory.getUserDAO().getUserById(id);
    }

    public boolean updateUser(User user) {
        return DAOFactory.getUserDAO().updateUser(user);
    }

    public boolean deleteUser(int id) {
        return DAOFactory.getUserDAO().deleteUser(id);
    }
}