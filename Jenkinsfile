pipeline {
    agent { label 'Redhat_Slave' }
    
    environment {
        DOCKER_IMAGE = "abhi-frontend"
        // Yahan apna Docker Hub username dalo
        DOCKER_HUB_USER = "abhiraj328" 
    }

    stages {
        stage('Cleanup Environment') {
            steps {
                deleteDir()
                echo "🗑️ Purana kachra saaf ho gaya!"
            }
        }

        stage('Git Checkout') {
            steps {
                // Tumhara GitHub URL yahan set hai
                git branch: 'main', url: 'https://github.com/abhishek85607/Abhi-ecommerce-devsecops.git'
            }
        }

        stage('Trivy FS Scan') {
            steps {
                script {
                    echo "🔍 Scanning Source Code for security bugs..."
                    sh "trivy fs . > trivy-fs-report.txt"
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo "📦 Building Docker Image..."
                sh "sudo docker build -t ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    echo "🛡️ Scanning Docker Image for CRITICAL vulnerabilities..."
                    // Agar koi CRITICAL bug mila toh build yahi fail ho jayega
                    sh "trivy image --severity CRITICAL --exit-code 1 ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Docker Push to Hub') {
            steps {
                script {
                    // 'docker-hub-creds' wahi ID hai jo tumne Jenkins Credentials mein banayi hai
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        
                        echo "🔑 Logging into Docker Hub..."
                        sh "echo ${DOCKER_PASS} | sudo docker login -u ${DOCKER_USER} --password-stdin"
                        
                        echo "🏷️ Tagging and Pushing Image..."
                        // Image ko build number aur 'latest' dono tags ke saath push karenge
                        sh "sudo docker tag ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_USER}/${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                        sh "sudo docker tag ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_USER}/${env.DOCKER_IMAGE}:latest"
                        
                        sh "sudo docker push ${DOCKER_USER}/${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                        sh "sudo docker push ${DOCKER_USER}/${env.DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            // Security report ko Jenkins dashboard pe save karna
            archiveArtifacts artifacts: 'trivy-fs-report.txt', fingerprint: true
            // Logout karna security ke liye best practice hai
            sh "sudo docker logout || true"
            echo "✅ Bhai Abhishek, Pipeline successfully finish ho gayi!"
        }
    }
}
