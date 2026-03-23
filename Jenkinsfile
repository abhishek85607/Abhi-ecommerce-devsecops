pipeline {
    agent { label 'Redhat_Slave' }
    
    environment {
        DOCKER_IMAGE = "Abhi-frontend"
        REGISTRY_USER = "abhiraj328" // Apna DockerHub username dalo
    }

    stages {
        stage('Cleanup') {
            steps {
                deleteDir() // Har baar purana kachra saaf
            }
        }
         stage('Trivy FS Scan') {
            steps {
                script {
                    echo "🔍 Scanning Source Code for Vulnerabilities..."
                    // Isse report file banegi
                    sh "trivy fs . > trivy-fs-report.txt"
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "sudo docker build -t ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    echo "🛡️ Scanning Docker Image: ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    // Agar CRITICAL vulnerability mili toh build fail ho jayega (--exit-code 1)
                    sh "trivy image --severity CRITICAL --exit-code 1 ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                }
            }
        }
    }

    post {
        always {
            // Jenkins Dashboard par report file save karne ke liye
            archiveArtifacts artifacts: 'trivy-fs-report.txt', fingerprint: true
            echo "Pipeline finished. Check Artifacts for Security Report."
        }
    }
}
