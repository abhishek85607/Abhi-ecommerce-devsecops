pipeline {
    agent { label 'Redhat_Slave' }
    
    environment {
        DOCKER_IMAGE = "abhi-frontend"
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
                git branch: 'main', url: 'https://github.com/abhishek85607/Abhi-ecommerce-devsecops.git'
            }
        }

        // --- NAYA SONARQUBE SECTION SHURU ---
        stage('SonarQube Analysis') {
            steps {
                script {
                    echo "🛡️ Code Quality Check shuru ho raha hai..."
                    // 'sonar-server' aur 'sonar-scanner' wahi naam hain jo tumne Jenkins Tools/System mein diye the
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('sonar-server') {
                        sh "${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=ecommerce-project \
                        -Dsonar.projectName=ecommerce-project \
                        -Dsonar.sources=."
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Ye pipeline ko rok dega agar SonarQube ne 'Fail' bola
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        // --- NAYA SONARQUBE SECTION KHATAM ---

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
                    sh "trivy image --severity CRITICAL --exit-code 1 ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Docker Push to Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        echo "🔑 Logging into Docker Hub..."
                        sh "echo ${DOCKER_PASS} | sudo docker login -u ${DOCKER_USER} --password-stdin"
                        
                        echo "🏷️ Tagging and Pushing Image..."
                        sh "sudo docker tag ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_USER}/${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                        sh "sudo docker tag ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_USER}/${env.DOCKER_IMAGE}:latest"
                        
                        sh "sudo docker push ${DOCKER_USER}/${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                        sh "sudo docker push ${DOCKER_USER}/${env.DOCKER_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "☸️ Deploying to Kubernetes (Minikube)..."
                    sh "kubectl apply -f k8s/deploy.yaml"
                    
                    echo "🚀 Checking Deployment Status..."
                    sh "kubectl get pods"
                    sh "kubectl get svc"
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-fs-report.txt', fingerprint: true
            sh "sudo docker logout || true"
            echo "✅ Bhai Abhishek, Pipeline with DevSecOps & K8s successfully finish ho gayi!"
        }
    }
}
