package org.techmart.ejb.remote;

import jakarta.ejb.Remote;
import org.techmart.entity.User;
import java.util.List;

@Remote // Marks this as an enterprise remote interface handle
public interface UserServiceRemote {
    User registerUser(User user);
    User loginUser(String email, String password);
    User getUserByEmail(String email);
    List<User> getAllUsers();
}