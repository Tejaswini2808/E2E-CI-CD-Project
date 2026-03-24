pipeline {
    agent any

    environment {
         DOCKER_IMAGE = "tejaswini2808/myflaskapp"
         TAG = "v1.${BUILD_NUMBER}"  
    }
    stages {

        stage('Setup') {
            steps {
                sh "./venv/bin/python -m pip install -r requirements.txt"
            }
        }
        stage('Test') {
            steps {
                sh "./venv/bin/python -m pytest"
            }
        }
        stage('Login to docker hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                sh 'echo ${PASSWORD} | docker login -u ${USERNAME} --password-stdin'
                }
                echo 'Login successfully'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}:${TAG} .'
                echo "Docker image build successfully"
                sh 'docker image ls'
            }
        }
        stage('Push Docker Image') {
            steps {
                sh 'docker push ${DOCKER_IMAGE}:${TAG}'
                echo "Docker Image push successfully"
            }
        }  
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                       sed -i "s|image:.*|image: $DOCKER_IMAGE:$TAG|g" flask-deployment.yaml
                       kubectl apply -f flask-deployment.yaml
                    '''
                }
            }
        }
        stage('Verify Deployment') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl rollout status deployment/flaskapp-deployment
                    '''
                }
            }
        }
        
    }
}
