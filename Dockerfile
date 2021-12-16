FROM maven:3.8.4-jdk-11 as MAVEN_BUILD
COPY ./ ./
RUN mvn -B clean install package -q -DargsLine="-XX:MaxRAM=1g -Xmx=256m"
ENTRYPOINT "ls -ahl target/"

FROM openjdk:11.0.7-jdk-slim
COPY --from=MAVEN_BUILD /${JAR_WORKDIR}/target/${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar ${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar

ENTRYPOINT java
CMD -jar ${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar
