pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t student-app:v1 .'
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                docker rm -f student-app || true

                docker run -d \
                  --name student-app \
                  -p 3000:3000 \
                  student-app:v1
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh 'curl http://localhost:3000'
            }
        }
    }
}
