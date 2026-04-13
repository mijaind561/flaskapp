pipeline {
    agent any
    environment {
        CONTAINER_ID = ""
        SUM_PY_PATH = "${WORKSPACE}/sum.py"
        DIR_PATH = "${WORKSPACE}"
        TEST_FILE_PATH = "${WORKSPACE}/test_variables.txt"
    }
    stages {
        stage('Build') {
            steps {
                bat "docker build -t sum-app ${DIR_PATH}"
            }
        }
        stage('Run') {
            steps {
                script {
                    def output = bat(script: "docker run -d sum-app", returnStdout: true)
                    def lines = output.split('\n')
                    CONTAINER_ID = lines[-1].trim()
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    def testLines = readFile(TEST_FILE_PATH).split('\n')
                    for (line in testLines) {
                        def vars = line.split(' ')
                        if (vars.size() < 3) continue
                        
                        def arg1 = vars[0]
                        def arg2 = vars[1]
                        def expectedSum = vars[2].toFloat()
                        
                        def output = bat(script: "docker exec ${CONTAINER_ID} python /app/sum.py ${arg1} ${arg2}", returnStdout: true)
                        def result = output.split('\n')[-1].trim().toFloat()
                        
                        if (result == expectedSum) {
                            echo "SUCCESS: ${arg1} + ${arg2} = ${result}"
                        } else {
                            error "FAILURE: Expected ${expectedSum} but got ${result}"
                        }
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                bat "docker login"
                bat "docker tag sum-app your_dockerhub_username/sum-app:latest"
                bat "docker push your_dockerhub_username/sum-app:latest"
            }
        }
    }
    post {
        always {
            bat "docker stop ${CONTAINER_ID}"
            bat "docker rm ${CONTAINER_ID}"
        }
    }
}