pipeline {
    agent any
    stages {
        stage("Init") {
            steps {
                echo 'BE FIRE NOT TO BURN, BE FIRE TO SEND LIGHT'
            }
        }
        stage("Build") {
            agent { dockerfile true}
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
