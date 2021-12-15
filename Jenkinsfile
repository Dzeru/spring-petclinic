pipeline {
    agent {
        docker {
            image 'maven:3.8.1-adoptopenjdk-11'
            args '-v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage("init") {
            steps {
                echo 'init init init'
            }
        }
        stage("build") {
            steps {
                sh 'mvn clean install package'
            }
        }
        stage("test") {
            sh 'mvn test'
        }
    }
    post {
        always {
            echo 'postirony'
        }
    }
}
