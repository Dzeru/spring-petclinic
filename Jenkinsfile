def nameNetwork(String prefix) {
    return prefix + "-${env.BUILD_TAG}-" + UUID.randomUUID().toString()
}

def petclinicNetwork
def curlNetwork

def nameContainer(String prefix) {
    return prefix + "-cont-${env.BUILD_TAG}-" + UUID.randomUUID().toString()
}

def petclinicContainer
def curlContainer

def checkCurlOutput(String curlOutput) {
    return curlOutput.contains('<title>PetClinic :: a Spring Framework demonstration</title>')
}

pipeline {
    agent any
    environment {
        JAR_VERSION = sh (returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout').trim()
        JAR_ARTIFACT_ID = sh (returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout').trim()
        DOCKER_HUB_VERSION = JAR_VERSION.replace("-SNAPSHOT", "-snapshot")
        DOCKER_HUB_USER = 'dzeru'
        DOCKER_HUB_REPOSITORY = 'spring-petclinic'
        CURL_NAME = 'petclinic-curl'
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
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'docker_hub_credentials', usernameVariable: 'DOCKER_HUB_USER', passwordVariable: 'DOCKER_HUB_PASSWORD')
                    ]) {
                    sh 'echo ${DOCKER_HUB_PASSWORD} | docker login -u ${DOCKER_HUB_USER} --password-stdin'
                }
            }
        }
        stage("Push to Docker Hub") {
            steps {
                sh 'docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_VERSION}'
            }
        }
        stage("Pull from Docker Hub") {
            steps {
                sh 'docker pull ${DOCKER_HUB_USER}/${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_VERSION}'
            }
        }
        stage("Create networks") {
            steps {
                script {
                    petclinicNetwork = nameNetwork('petclinic')
                    curlNetwork = nameNetwork('curl')
                }
                sh "docker network create ${petclinicNetwork}"
                sh "docker network create ${curlNetwork}"
            }
        }
        stage("Prepare Curl image") {
            steps {
                script {
                    docker.build("${CURL_NAME}", "-f DockerfileCurl .")
                }
            }
        }
        stage("Test Spring Pet Clinic") {
            steps {
                script {
                    petclinicContainer = nameContainer('petclinic')
                    curlContainer = nameContainer('curl')
                    sh ("docker run --name ${petclinicContainer} --network ${petclinicNetwork} -p 9000:9000 ${DOCKER_HUB_USER}/${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_VERSION} &")
                    def petclinicContainerRunning = sh(script: "docker container inspect -f '{{.State.Running}}' ${petclinicContainer}", returnStdout: true).trim()
                    while (!petclinicContainerRunning.equals("true")) {
                        println("Waiting for Spring Pet Clinic container readiness...")
                        sleep(5)
                        petclinicContainerRunning = sh(script: "docker container inspect -f '{{.State.Running}}' ${petclinicContainer}", returnStdout: true).trim()
                    }
                    def petclinicAppRunningCheck = "Tomcat started on port"
                    def petclinicAppRunning = sh(script: "docker container logs ${petclinicContainer}", returnStdout: true)
                    while (null == petclinicAppRunning || !petclinicAppRunning.contains(petclinicAppRunningCheck)) {
                        println("Waiting for Spring Pet Clinic app readiness...")
                        sleep(5)
                        petclinicAppRunning = sh(script: "docker container logs ${petclinicContainer}", returnStdout: true)
                    }
                    def petclinicGateway = sh (
                        script: "docker inspect -f '{{range.NetworkSettings.Networks}}{{.Gateway}}{{end}}' ${petclinicContainer}",
                        returnStdout: true).trim()
                    def curlOutput = sh (script: "docker run --name ${curlContainer} --network ${curlNetwork} ${CURL_NAME} ${petclinicGateway}:9000",
                        returnStdout: true)
                    if (!checkCurlOutput(curlOutput)) {
                        warnError(message: 'Curl FAILED. Spring Pet Clinic returned wrong response.', buildResult: 'UNSTABLE', stageResult: 'UNSTABLE')
                    } else {
                        println("Curl is SUCCESSFUL. Lets celebrate it with the happy cat:")
                        println ("""
                                                  
            .                .                    
            :"-.          .-";                    
            |:`.`.__..__.'.';|                    
            || :-"      "-; ||                    
            :;              :;                    
            /  .==.    .==.  \\                    
           :      _.--._      ;                   
           ; .--.' `--' `.--. :                   
          :   __;`      ':__   ;                  
          ;  '  '-._:;_.-'  '  :                  
          '.       `--'       .'                  
           ."-._          _.-".                   
         .'     ""------""     `.                 
        /`-                    -'\\                
       /`-                      -'\\               
      :`-   .'              `.   -';              
      ;    /                  \\    :              
     :    :                    ;    ;             
     ;    ;                    :    :             
     ':_:.'                    '.;_;'             
        :_                      _;                
        ; "-._                -" :`-.     _.._    
        :_          ()          _;   "--::__. `.  
         \"-                  -"/`._           :  
        .-"-.                 -"-.  ""--..____.'  
       /         .__  __.         \\               
      : / ,       / "" \\       . \\ ;              
       "-:___..--"      "--..___;-"               
                            """)
                    }
                }
            }
        }
    }
    post { 
        always {
            sh "docker stop ${petclinicContainer}"
            sh "docker container rm ${petclinicContainer}"
            sh "docker network rm ${petclinicNetwork}"
            sh "docker stop ${curlContainer}"
            sh "docker container rm ${curlContainer}"
            sh "docker network rm ${curlNetwork}"
        }
        success { 
            withCredentials([string(credentialsId: 'telegram_bot_token', variable: 'TOKEN'), string(credentialsId: 'telegram_notification_channel', variable: 'CHAT_ID')]) {
            sh """
                curl -s -X POST ${TELEGRAM_API_URL}${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text='SUCCESSFUL build *${env.BUILD_TAG}* for *${env.CHANGE_BRANCH}*.\n\nBuild is triggered with change *${env.CHANGE_TITLE}* (${env.CHANGE_URL}) by ${env.GIT_AUTHOR_NAME}, email: ${env.GIT_AUTHOR_EMAIL}.'
            """
            }
        }
        failure { 
            withCredentials([string(credentialsId: 'telegram_bot_token', variable: 'TOKEN'), string(credentialsId: 'telegram_notification_channel', variable: 'CHAT_ID')]) {
            sh """
                curl -s -X POST ${TELEGRAM_API_URL}${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text='FAILED build *${env.BUILD_TAG}* for *${env.CHANGE_BRANCH}*.\n\nBuild is triggered with change *${env.CHANGE_TITLE}* (${env.CHANGE_URL}) by ${env.GIT_AUTHOR_NAME}, email: ${env.GIT_AUTHOR_EMAIL}.'
            """
            }
        }
    }
}
