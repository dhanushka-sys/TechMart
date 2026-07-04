package org.techmart.web.servlet;

import jakarta.ejb.EJB;
import jakarta.inject.Inject;
import jakarta.jms.JMSContext;
import jakarta.jms.MapMessage;
import jakarta.annotation.Resource;
import jakarta.jms.Topic;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.techmart.ejb.local.UserServiceLocal;
import org.techmart.entity.User;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    @EJB
    private UserServiceLocal userService;

    @Inject
    private JMSContext jmsContext;

    @Resource(lookup = "jms/inventoryTopic")
    private Topic inventoryTopic;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("login".equals(action)) {
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String ipAddress = req.getRemoteAddr();
            String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

            User user = userService.loginUser(email, password);

            try {
                MapMessage alertMsg = jmsContext.createMapMessage();
                alertMsg.setString("email", email);
                alertMsg.setString("ipAddress", ipAddress);
                alertMsg.setString("timestamp", timestamp);

                if (user != null) {
                    // Login Success
                    alertMsg.setString("eventType", "LOGIN_SUCCESS");
                    jmsContext.createProducer().send(inventoryTopic, alertMsg);

                    HttpSession session = req.getSession(true);
                    session.setAttribute("user", user);

                    resp.setContentType("application/json");
                    resp.getWriter().write("{\"success\": true, \"message\": \"Login successful\", \"name\": \"" + user.getName() + "\"}");
                } else {
                    // Login Failure
                    alertMsg.setString("eventType", "LOGIN_FAILURE");
                    jmsContext.createProducer().send(inventoryTopic, alertMsg);

                    resp.setContentType("application/json");
                    resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    resp.getWriter().write("{\"success\": false, \"message\": \"Invalid email or password\"}");
                }
            } catch (Exception e) {
                resp.setContentType("application/json");
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("{\"success\": false, \"message\": \"System error: " + e.getMessage() + "\"}");
            }
        } else if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }
}
