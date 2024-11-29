# Use the official Maven image to build the application
FROM maven:3.8.6-openjdk-11 as build

# Set the working directory in the container
WORKDIR /app

# Copy the pom.xml and the source code to the container
COPY pom.xml ./
COPY src ./src

# Run Maven to build the application and package the JAR into the target folder
RUN mvn clean install -DskipTests

# Use the Red Hat UBI minimal base image for the final image
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5

# Install Java 11 runtime
RUN microdnf install --nodocs java-11-openjdk-headless && microdnf clean all

# Set the working directory for the application in the final container
WORKDIR /work/

# Copy the built JAR from the previous build stage into the final image
COPY --from=build /app/target/*.jar /work/application.jar

# Expose the port the app will run on
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "application.jar"]