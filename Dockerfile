FROM maven:3.8.4-jdk-11 as MAVEN_BUILD
WORKDIR ${JAR_WORKDIR}
COPY src /app/src
COPY pom.xml /app/
RUN cd /app
RUN mvn -B clean install package -q
ENTRYPOINT "ls -ahl target/"

FROM openjdk:11.0.7-jdk-slim
COPY --from=MAVEN_BUILD ${JAR_WORKDIR}/target/${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar ${JAR_WORKDIR}/${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar

ENTRYPOINT java
CMD -jar ${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar