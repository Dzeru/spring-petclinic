ARG JAR_WORKDIR=app
FROM maven:3.6.0-jdk-11 as build
WORKDIR /${JAR_WORKDIR}
COPY src ./src
COPY pom.xml ./
RUN mvn -B clean package
ENTRYPOINT "ls -ahl target/"

FROM openjdk:11.0.7-jre-slim
COPY --from=build /${JAR_WORKDIR}/target/${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar ${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar

ENTRYPOINT java
CMD -jar ${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar