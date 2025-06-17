pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = "hibatullahsyauqi/premiere-league"
        DOCKER_CREDENTIALS_ID = "hibatullahsyauqi"
        KUBECONFIG_CREDENTIALS_ID = "hibatullahsyauqi"
    }

    stages {
        // Stage 1: Get the code from GitHub
        stage('Checkout') {
            steps {
                echo 'Checking out source code from Git...'
                checkout scm
            }
        }
        // Stage 2: Build the application and run tests using Maven
        stage('Build & Test') {
            steps {
                echo 'Building the application and running tests...'
                sh './mvnw clean install'
            }
        }
        // Stage 3: Build the Docker image using the Dockerfile
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        // Stage 4: Push the image to Docker Hub repository
        stage('Push Docker Image') {
            steps {
                echo "Logging in and pushing Docker image to Docker Hub..."
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                    sh "docker push ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        // Stage 5: Deploy the new version to Kubernetes
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to Kubernetes...'
                withKubeconfig(credentialsId: env.KUBECONFIG_CREDENTIALS_ID) {
                    sh "sed -i 's|image: .*|image: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}|g' k8s/deployment.yaml"
                    sh "kubectl apply -f k8s/"
                    sh "kubectl rollout status deployment/premiere-league-deployment"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished. Cleaning up.'
            sh 'docker logout'
        }
    }
}