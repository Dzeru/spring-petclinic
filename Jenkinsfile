pipeline {
    agent any
    environment {
        JAR_VERSION = sh (returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout').trim()
        JAR_ARTIFACT_ID = sh (returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout').trim()
        DOCKER_HUB_CREDENTIALS = credentials('docker_hub_credentials')
        DOCKER_HUB_REPOSITORY = 'spring-petclinic'
    }
    stages {
        stage("Init") {
            steps {
                echo 'BE FIRE NOT TO BURN, BE FIRE TO SEND LIGHT'
            }
        }
        stage("Build") {
            agent {
                dockerfile {
                    additionalBuildArgs "--build-arg JAR_VERSION=${JAR_VERSION} --build-arg JAR_ARTIFACT_ID=${JAR_ARTIFACT_ID}"
                    args "-t ${DOCKER_HUB_CREDENTIALS}/${DOCKER_HUB_REPOSITORY}:${JAR_VERSION}"
                    label "${DOCKER_HUB_CREDENTIALS}/${DOCKER_HUB_REPOSITORY}:${JAR_VERSION}"
                }
            }
            steps {
                echo 'SOMEWHERE SHOULD BE DOCKERFILE LOGS'
            }
        }
        stage("Push to Docker Hub") {
            steps {
                sh "docker push ${DOCKER_HUB_CREDENTIALS}/${DOCKER_HUB_REPOSITORY}:${JAR_VERSION}"
            }
        }
        stage("Pull from Docker Hub") {
            steps {
                sh "docker pull ${DOCKER_HUB_CREDENTIALS}/${DOCKER_HUB_REPOSITORY}:${JAR_VERSION}"
            }
        }
        stage("Test Image") {
            steps {
                echo "curl test..."
            }
        }
    }
    post {
        always {
            echo 'postirony'
        }
    }
}
