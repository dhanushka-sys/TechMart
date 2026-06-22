package org.techmart.ejb.bean;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.techmart.ejb.local.UserServiceLocal;
import org.techmart.ejb.remote.UserServiceRemote;
import org.techmart.entity.User;
import java.util.List;

@Stateless
public class UserServiceBean implements UserServiceLocal, UserServiceRemote {

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @Override
    public User registerUser(User user) {
        em.persist(user);
        return user;
    }

    @Override
    public User loginUser(String email, String password) {
        try {
            return em.createQuery("SELECT u FROM User u WHERE u.email = :email AND u.password = :password", User.class)
                    .setParameter("email", email)
                    .setParameter("password", password)
                    .getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public User getUserByEmail(String email) {
        try {
            return em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public List<User> getAllUsers() {
        return em.createQuery("SELECT u FROM User u", User.class).getResultList();
    }
}