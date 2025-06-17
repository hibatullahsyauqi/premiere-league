# --- Stage 1: Build the application with Maven and Java 21 ---
FROM maven:3.9-eclipse-temurin-21 AS build

# Set the working directory
WORKDIR /app

# Copy pom.xml first to leverage Docker's layer caching for dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of your source code
COPY src ./src

# Build the application and create the .jar file. We skip tests here as they
# will be run in a separate stage in the CI/CD pipeline.
RUN mvn clean package -DskipTests


# --- Stage 2: Create the final, lightweight production image ---
FROM eclipse-temurin:21-jre-jammy

# Set the working directory
WORKDIR /app

# Define an argument for the JAR file path for clarity
ARG JAR_FILE=target/premiere-league-0.0.1-SNAPSHOT.jar

# Copy the built .jar file from the 'build' stage to our final image
COPY --from=build /app/${JAR_FILE} app.jar

# Expose the default Spring Boot port
EXPOSE 8080

# The command to run your application when the container starts.
# It will use environment variables for the database connection.
ENTRYPOINT ["java", "-jar", "app.jar"]