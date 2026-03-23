pipeline {
    agent { label 'Redhat_Slave' }
    
    environment {
        DOCKER_IMAGE = "abhi-frontend"
    }
 
    stages {
        stage('Cleanup Environment') {
            steps {
                // Pehle purana kachra saaf karo
                deleteDir()
            }
        }

        stage('Git Checkout') {
            steps {
                git 'https://github.com/abhishek85607/Abhi-ecommerce-devsecops.git'
            }
        }

        stage('Trivy FS Scan') {
            steps {
                script {
                    echo "🔍 Scanning Source Code..."
                    sh "trivy fs . > trivy-fs-report.txt"
                }
            }
        }

        stage('Docker Build') {
            steps {
                // Ab code delete nahi hua hoga, toh build chal jayega
                sh "sudo docker build -t ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    echo "🛡️ Scanning Docker Image..."
                    sh "trivy image --severity CRITICAL --exit-code 1 ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-fs-report.txt', fingerprint: true
            echo "Pipeline finished."
        }
    }
}
