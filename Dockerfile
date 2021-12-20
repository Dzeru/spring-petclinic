#syntax=docker/dockerfile:experimental
FROM openjdk:11-jre-slim AS build
WORKDIR /app

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2,rw ./mvnw -B clean package

FROM openjdk:11-jre-slim

COPY --from=build /app/target/${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar /${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar

ENTRYPOINT java
CMD -jar ${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar