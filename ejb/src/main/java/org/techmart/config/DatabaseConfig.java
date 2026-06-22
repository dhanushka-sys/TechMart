package org.techmart.config;

import jakarta.annotation.sql.DataSourceDefinition;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;

@Singleton
@Startup
@DataSourceDefinition(
        name = "java:app/jdbc/TechMartDS",
        className = "com.mysql.cj.jdbc.MysqlDataSource",
        user = "root",
        password = "dbworld",
        databaseName = "techmart_db",
        serverName = "localhost",
        portNumber = 3306,
        properties = {"useSSL=false", "allowPublicKeyRetrieval=true"}
)
public class DatabaseConfig {
}