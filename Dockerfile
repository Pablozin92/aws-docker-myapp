# Stage 1: Build using Maven
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory inside the container
WORKDIR /app

# Copy Maven project files
COPY Java-Spring-Test/pom.xml .
COPY Java-Spring-Test/src ./src

# Build the Spring Boot application (skip tests for faster build)
RUN mvn clean package -DskipTests

# Optional: Debug output to check JAR name (uncomment if needed)
# RUN ls -lah target/

# Stage 2: Run with a slim base image
FROM eclipse-temurin:17-jre-alpine

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Switch to non-root user
USER appuser

# Set working directory
WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the backend port
EXPOSE 8080

# Health check for ECS and Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl --fail http://localhost:8080/actuator/health || exit 1

# Run the Spring Boot application
CMD ["java", "-jar", "app.jar"]
