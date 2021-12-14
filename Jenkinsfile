pipeline {
    agent any
    stages {
        stage("init") {
            steps {
                echo 'init init init'
            }
        }
        stage("build") {
            steps {
                echo 'buiiiild buiiiild buiiiild'
            }
        }
    }
    post {
        always {
            echo 'postirony'
        }
    }
}
