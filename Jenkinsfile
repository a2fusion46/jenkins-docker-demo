pipeline {
    agent any

    triggers {
        // Poll SCM every 5 minutes for automated builds on git push
        pollSCM('H/5 * * * *')
    }

    environment {
        IMAGE_NAME = 'jenkins-docker-demo'
        CONTAINER_NAME = 'jenkins-docker-demo-app'
        HOST_PORT = '8081'
        CONTAINER_PORT = '80'
        CREDS_ID = 'dockerhub-creds'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo '=== Stage 1: Checkout Source Code ==='
                checkout scm
            }
        }

        stage('Validate Project Files') {
            steps {
                echo '=== Stage 2: Validate Required Files ==='
                sh '''
                    echo "Checking presence of essential files..."
                    test -f Dockerfile || { echo "ERROR: Dockerfile missing!"; exit 1; }
                    test -f project/index.html || { echo "ERROR: project/index.html missing!"; exit 1; }
                    test -f project/style.css || { echo "ERROR: project/style.css missing!"; exit 1; }
                    test -f project/script.js || { echo "ERROR: project/script.js missing!"; exit 1; }
                    echo "All required files verified successfully."
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo "=== Stage 3: Building Docker Image (${IMAGE_NAME}:${BUILD_NUMBER}) ==="
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Docker Hub Push') {
            steps {
                echo '=== Stage 4 & 5: Authenticate & Push to Docker Hub ==='
                withCredentials([usernamePassword(credentialsId: "${CREDS_ID}", usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh '''
                        echo "Authenticating with Docker Hub..."
                        echo "${DOCKERHUB_PASS}" | docker login docker.io -u "${DOCKERHUB_USER}" --password-stdin

                        echo "Tagging Docker images for Docker Hub repository: docker.io/${DOCKERHUB_USER}/${IMAGE_NAME}..."
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} docker.io/${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} docker.io/${DOCKERHUB_USER}/${IMAGE_NAME}:latest

                        echo "Pushing tagged images to Docker Hub..."
                        docker push docker.io/${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
                        docker push docker.io/${DOCKERHUB_USER}/${IMAGE_NAME}:latest

                        echo "Logging out of Docker Hub..."
                        docker logout docker.io
                    '''
                }
            }
        }

        stage('Deploy to Local Docker') {
            steps {
                echo "=== Stage 6: Deploy Container on Port ${HOST_PORT} ==="
                withCredentials([usernamePassword(credentialsId: "${CREDS_ID}", usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh '''
                        echo "Pulling latest image from Docker Hub registry..."
                        docker pull docker.io/${DOCKERHUB_USER}/${IMAGE_NAME}:latest

                        echo "Stopping and removing existing container if running..."
                        docker stop ${CONTAINER_NAME} || true
                        docker rm -f ${CONTAINER_NAME} || true

                        echo "Starting new container on port ${HOST_PORT}..."
                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            -p ${HOST_PORT}:${CONTAINER_PORT} \
                            --restart unless-stopped \
                            docker.io/${DOCKERHUB_USER}/${IMAGE_NAME}:latest

                        echo "Container launched successfully."
                    '''
                }
            }
        }

        stage('Verify Health Check') {
            steps {
                echo '=== Stage 7: Verify Application HTTP 200 Status ==='
                sh '''
                    echo "Probing http://localhost:${HOST_PORT}..."
                    HEALTHY=0
                    for i in $(seq 1 15); do
                        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${HOST_PORT}/ || echo "000")
                        if [ "${HTTP_STATUS}" = "200" ]; then
                            echo "SUCCESS: Application responded with HTTP 200 OK on attempt ${i}!"
                            HEALTHY=1
                            break
                        fi
                        echo "Attempt ${i}/15: HTTP ${HTTP_STATUS}. Retrying in 2 seconds..."
                        sleep 2
                    done

                    if [ "${HEALTHY}" -ne 1 ]; then
                        echo "ERROR: Health check failed! Showing container logs:"
                        docker logs ${CONTAINER_NAME} || true
                        exit 1
                    fi
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline run completed for build #${BUILD_NUMBER}."
        }
        success {
            echo "Pipeline SUCCESS: Application is live at http://localhost:${HOST_PORT}"
        }
        failure {
            echo "Pipeline FAILED: Please check stage logs above for details."
        }
    }
}
