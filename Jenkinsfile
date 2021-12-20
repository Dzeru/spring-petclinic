pipeline {
    agent any
    environment {
        JAR_VERSION = sh (returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout').trim()
        JAR_ARTIFACT_ID = sh (returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout').trim()
        DOCKER_HUB_VERSION = JAR_VERSION.replace("-SNAPSHOT", "-snapshot")
        DOCKER_HUB_USER = 'dzeru'
        DOCKER_HUB_REPOSITORY = 'spring-petclinic'
        TELEGRAM_API_URL = 'https://api.telegram.org/bot'
    }
    stages {
        stage("Init") {
            steps {
                echo 'BE FIRE NOT TO BURN, BE FIRE TO SEND LIGHT'
            }
        }
        stage("Build") {
            steps {
                script {
                    docker.build("${DOCKER_HUB_USER}/${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_VERSION}", "--build-arg JAR_VERSION=${JAR_VERSION} --build-arg JAR_ARTIFACT_ID=${JAR_ARTIFACT_ID} -f Dockerfile .")
                }
            }
        }
        stage("Login to Docker Hub") {
            when {
                expression {
                    env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev'
                }
            }
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'docker_hub_credentials', usernameVariable: 'DOCKER_HUB_USER', passwordVariable: 'DOCKER_HUB_PASSWORD')
                    ]) {
                    sh 'echo ${DOCKER_HUB_PASSWORD} | docker login -u ${DOCKER_HUB_USER} --password-stdin'
                }
            }
        }
        stage("Push to Docker Hub") {
            when {
                expression {
                    env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev'
                }
            }
            steps {
                sh 'docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_VERSION}'
            }
        }
        stage("Pull from Docker Hub") {
            when {
                expression {
                    env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev'
                }
            }
            steps {
                sh 'docker pull ${DOCKER_HUB_USER}/${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_VERSION}'
            }
        }
        stage("Run Spring Pet Clinic") {
            when {
                expression {
                    env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev'
                }
            }
            steps {
                sh "docker run -p 9000:9000 ${DOCKER_HUB_USER}/${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_VERSION}"
            }
        }
        stage("Test Image") {
            steps {
                echo "curl test..."
            }
        }
    }
    post { 
        success { 
            withCredentials([string(credentialsId: 'telegram_bot_token', variable: 'TOKEN'), string(credentialsId: 'telegram_notification_channel', variable: 'CHAT_ID')]) {
            sh ("""
                curl -s -X POST ${TELEGRAM_API_URL}${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text='Successful build *${env.BUILD_TAG}* for branch *${env.GIT_BRANCH}*'
            """)
            }
        }
        failure { 
            withCredentials([string(credentialsId: 'telegram_bot_token', variable: 'TOKEN'), string(credentialsId: 'telegram_notification_channel', variable: 'CHAT_ID')]) {
            sh ("""
                curl -s -X POST ${TELEGRAM_API_URL}${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text='FAILED build *${env.BUILD_TAG}* for branch *${env.GIT_BRANCH}*'
            """)
            }
        }
    }
}
