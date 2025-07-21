# -------- Build Stage --------
FROM openjdk:21-jdk-slim AS builder

# Install Maven and basic tools
RUN apt-get update && \
    apt-get install -y maven curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the Maven project descriptor
COPY pom.xml .

# Pre-download dependencies for better caching
RUN mvn dependency:go-offline -B

# Copy the rest of the project
COPY src ./src

# Package the application (skip tests)
RUN mvn clean package -DskipTests

# -------- Runtime Stage --------
FROM openjdk:21-jdk-slim

# Set working directory
WORKDIR /app

# Copy the compiled JAR from the builder stage
COPY --from=builder /app/target/globaluser-0.0.1-SNAPSHOT.jar app.jar

# Expose application port
EXPOSE 8094

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
