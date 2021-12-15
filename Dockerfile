FROM maven:3.8.2-adoptopenjdk-11 as MAVEN_BUILD
COPY ./ ./
RUN mvn clean install package -q

FROM openjdk:11.0.7-jdk-slim
COPY --from=MAVEN_BUILD /target/${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar /${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar

ENTRYPOINT java
CMD -jar ${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar