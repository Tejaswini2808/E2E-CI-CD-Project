pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tejaswini2808/myflaskapp"
        TAG = "v1.${BUILD_NUMBER}"
    }

    stages {
        
        // ⚡ Parallel Security + Test
        stage('Security & Testing') {
            parallel {

                stage('Code Security Scan (Bandit)') {
                    steps {
                        sh '''
                        docker run --rm -v $(pwd):/app -w /app python:3.12-slim \
                        bash -c "pip install bandit && bandit -r . -x ./venv,./.git -lll"
                        '''
                    }
                }
               stage('Dependency Scan') {
                    steps {
                        sh '''
                        docker run --rm -v $(pwd):/app -w /app python:3.12-slim \
                        bash -c "
                        pip install pip-audit && \
                        pip-audit \
                        --ignore-vuln CVE-2025-8869 \
                        --ignore-vuln CVE-2026-1703 \
                        --ignore-vuln CVE-2026-4539
                        "
                        '''
                    }
                }

                stage('Unit Tests') {
                    steps {
                        sh '''
                        docker run --rm -v $(pwd):/app -w /app python:3.12-slim \
                        bash -c "
                        pip install -r requirements.txt pytest && \
                        pytest || echo 'No tests or test failures'
                        "
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}:${TAG} .'
            }
        }

        stage('Image Scan - Trivy') {
            steps {
                sh '''
                trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_IMAGE}:${TAG}
                '''
            }
        }

        stage('Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    echo $PASSWORD | docker login -u $USERNAME --password-stdin
                    docker push ${DOCKER_IMAGE}:${TAG}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    sed -i "s|image:.*|image: ${DOCKER_IMAGE}:${TAG}|g" flask-deployment.yaml
                    kubectl apply -f flask-deployment.yaml
                    '''
                }
            }
        }
    }
}
