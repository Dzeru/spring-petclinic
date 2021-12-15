pipeline {
    agent any
    stages {
        stage("Build") {
            agent {
                { dockerfile true}
            }
            steps {
                echo 'SOMEWHERE SHOULD BE DOCKERFILE LOGS'
            }
        }
        stage("Upload to dockerhub") {
            steps {
                echo 'upload to dockerhub'
            }
        }
    }
    post {
        always {
            echo 'postirony'
        }
    }
}
