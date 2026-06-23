# TechMart Enterprise Deployment Guide

## Prerequisites
- Java SE Development Kit (JDK) 11 or 17
- MySQL Database Server 8.0+
- Payara Server 6 (Jakarta EE 10 Web / Full Profile)
- Apache Maven 3.8+

## Database Setup
1. Open the MySQL console or preferred client.
2. Execute the `schema.sql` script to create the database schema, tables, and insert seed data:
   ```sql
   source schema.sql;
   ```
3. Verify that the `techmart_db` database is successfully populated with tables (`users`, `products`, `inventory`, `orders`, `order_items`, `audit_logs`).

## Build Instructions
1. Navigate to the project root directory.
2. Run the Maven packaging command to compile and build the modules:
   ```bash
   mvn clean package
   ```
3. The build output will produce a deployable Enterprise Archive (EAR) at:
   `ear/target/TechMart-ear.ear`

## Payara Server Configuration
1. Start the Payara server instance.
2. Configure JDBC Connection Pool:
   - DataSource Classname: `com.mysql.cj.jdbc.MysqlDataSource`
   - Resource Type: `javax.sql.DataSource`
   - Name: `TechMartPool`
   - Properties:
     - `serverName`: `localhost`
     - `portNumber`: `3306`
     - `databaseName`: `techmart_db`
     - `user`: `root`
     - `password`: `dbworld`
3. Create a JDBC Resource:
   - JNDI Name: `java:app/jdbc/TechMartDS`
   - Pool Name: `TechMartPool`
4. Configure JMS Resources:
   - Connection Factory:
     - JNDI Name: `jms/connectionFactory`
     - Resource Type: `jakarta.jms.ConnectionFactory`
   - Topic:
     - JNDI Name: `jms/inventoryTopic`
     - Resource Type: `jakarta.jms.Topic`

## Deployment
1. Upload the generated `TechMart-ear.ear` archive through the Payara Admin Console or copy it into the `autodeploy/` folder of the server domain.
2. Access the modernization portal at:
   `http://localhost:8080/TechMart/`
