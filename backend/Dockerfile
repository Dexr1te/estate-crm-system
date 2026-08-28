# Stage 1: Build 
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Run 
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# The uploads folder is created here, owned by the runtime user: a named
# volume mounted over it inherits this ownership when it is first created,
# which is what lets a non-root container write deal documents into it.
RUN addgroup -S spring && adduser -S spring -G spring \
    && mkdir -p /app/uploads && chown -R spring:spring /app/uploads
USER spring:spring

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
