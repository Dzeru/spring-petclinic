pipeline {
    agent any
    environment {
        JAR_VERSION = sh (returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout').trim()
        JAR_ARTIFACT_ID = sh (returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout').trim()
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
                    args '-m 3072M'
                }
            }
            steps {
                echo 'SOMEWHERE SHOULD BE DOCKERFILE LOGS'
            }
        }
        stage("Upload to dockerhub") {
            steps {
                echo 'LETS PLAY WITH THE BLUE WHALE'
            }
        }
    }
    post {
        always {
            echo 'postirony'
        }
    }
}
