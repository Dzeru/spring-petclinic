#syntax=docker/dockerfile:experimental
FROM openjdk:11-slim-buster AS build
WORKDIR /app

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2,rw ./mvnw -B clean package

FROM openjdk:11-jre-slim-buster
ARG JAR_ARTIFACT_ID=spring-petclinic
ARG JAR_VERSION=UNKNOWN

COPY --from=build /app/target/${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar /${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar

EXPOSE 9000
RUN echo 'HELLO'

ENTRYPOINT ["java"]
CMD ["-jar" "-Dserver.port=9000" "${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar"]