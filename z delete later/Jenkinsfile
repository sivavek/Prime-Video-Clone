pipeline {
    agent any

    parameters {
        string(name: 'ECR_NAME', defaultValue: 'prime-video-clone', description: 'Enter the ECR repo name')
    }
    environment {
        SONARQUBE_SCANNER_HOME = tool 'SonarQubeScanner'
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_REGION = 'ap-south-1'
    }
    tools {
        nodejs 'NodeJS-18'
        jdk 'JDK-16'
    }
    stages {
        stage('Code Checkout') {
            steps {
                git branch: 'main', 
                url: 'https://github.com/sivavek/Prime-Video-Clone.git'
            }
        }

        stage('SonaQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    ${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectName=Prime-Video-Clone \
                    -Dsonar.projectKey=Prime-Video-Clone \
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-credentials-id'
                }
            }
        }

        stage('NPM Build') {
            steps {
                sh 'npm install'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL . > trivy-report.txt'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${params.ECR_NAME} .'
            }
        }

        stage('Create ECR Repo') {
            steps {
                withCredentials([string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                        aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                        aws configure set default.region ${AWS_REGION}
                        aws describe-repositories --repository-names ${ECR_NAME} --region ${AWS_REGION} || \
                        aws ecr create-repository --repository-name ${ECR_NAME} --region ${AWS_REGION}
                    '''
                }
            }

        }

        stage('Docker Push to ECR') {
            steps {
                withCredentials([string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        $(aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com)
                        docker tag ${ECR_NAME}:$BUILD_NUMBER ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$BUILD_NUMBER
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$BUILD_NUMBER
                    '''
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker rmi ${ECR_NAME}:$BUILD_NUMBER || true'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
        }
    }
}
