FROM maven:3.8.2-adoptopenjdk-11 as MAVEN_BUILD
COPY ./ ./
RUN mvn clean install package

FROM openjdk:11.0.7-jdk-slim
RUN mvn help:evaluate -Dexpression=project.version -q -DforceStdout > jarVersion.txt
RUN mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout > jarArtifactId.txt
RUN JAR_VERSION=$(cat jarVersion.txt)
RUN JAR_ARTIFACT_ID=$(cat jarArtifactId.txt)
RUN echo 'AAAAAA ${JAR_ARTIFACT_ID}-${JAR_VERSION}'
COPY --from=MAVEN_BUILD /target/${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar /${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar

ENTRYPOINT java
CMD -jar ${JAR_ARTIFACT_ID}-${JAR_VERSION}.jar