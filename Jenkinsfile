pipeline {
    agent any

    environment {
        // ID credentials da khai bao trong Jenkins (Manage Jenkins > Credentials)
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')

        // Thong tin registry va image
        DOCKER_REGISTRY   = 'docker.io'                       // doi thanh registry khac neu can, vd: your-registry.com
        DOCKER_IMAGE_NAME = 'phamquocdow/golang-ci-demo'
        IMAGE_TAG         = "${env.BUILD_NUMBER}"
        FULL_IMAGE_NAME   = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
        LATEST_IMAGE_NAME = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest"
    }

    options {
        // Tu dong don log cu, giu 10 build gan nhat
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('1. Compile ma nguon') {
            steps {
                echo "== Compiling Go source =="
                sh '''
                    go version
                    go mod download || true
                    CGO_ENABLED=0 GOOS=linux go build -o server .
                '''
            }
        }

        stage('2. Build Docker image') {
            steps {
                echo "== Building Docker image: ${FULL_IMAGE_NAME} =="
                sh """
                    docker build -t ${FULL_IMAGE_NAME} -t ${LATEST_IMAGE_NAME} .
                """
            }
        }

        stage('3. Push image len Registry') {
            steps {
                echo "== Pushing image len ${DOCKER_REGISTRY} =="
                sh """
                    echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login ${DOCKER_REGISTRY} -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin
                    docker push ${FULL_IMAGE_NAME}
                    docker push ${LATEST_IMAGE_NAME}
                """
            }
        }
    }

    post {
        always {
            echo "== Don dep: xoa image local va logout khoi registry =="
            sh """
                docker rmi ${FULL_IMAGE_NAME} || true
                docker rmi ${LATEST_IMAGE_NAME} || true
                docker logout ${DOCKER_REGISTRY} || true
                docker image prune -f || true
            """
        }
        success {
            echo "Pipeline chay thanh cong! Image da duoc push: ${FULL_IMAGE_NAME}"
        }
        failure {
            echo "Pipeline that bai. Kiem tra log ben tren de biet chi tiet."
        }
    }
}
