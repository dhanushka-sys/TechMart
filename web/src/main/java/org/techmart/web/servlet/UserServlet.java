package org.techmart.web.servlet;

import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.techmart.ejb.local.UserServiceLocal;
import org.techmart.entity.User;
import java.io.IOException;
import java.util.List;

@WebServlet("/users")
public class UserServlet extends HttpServlet {

    @EJB
    private UserServiceLocal userService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");

        String action = req.getParameter("action");

        if ("create".equals(action)) {
            User newUser = new User();
            newUser.setName(req.getParameter("name"));
            newUser.setEmail(req.getParameter("email"));
            newUser.setPassword(req.getParameter("password"));

            userService.registerUser(newUser);
            resp.getWriter().write("User registered successfully!");
        } else {
            List<User> users = userService.getAllUsers();
            resp.getWriter().write("<h2>Total Users Registered: " + users.size() + "</h2>");
            for (User u : users) {
                resp.getWriter().write("<p>" + u.getName() + " - " + u.getEmail() + "</p>");
            }
        }
    }
}