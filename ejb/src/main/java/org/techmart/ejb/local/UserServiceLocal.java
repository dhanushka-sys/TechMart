package org.techmart.ejb.local;

import jakarta.ejb.Local;
import org.techmart.entity.User;
import java.util.List;

@Local
public interface UserServiceLocal {
    User registerUser(User user);
    User loginUser(String email, String password);
    User getUserByEmail(String email);
    List<User> getAllUsers();
}