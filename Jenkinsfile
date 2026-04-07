pipeline {
    agent any
    environment {
        CONTAINER_ID = ""
        SUM_PY_PATH = "${WORKSPACE}/sum.py"
        DIR_PATH = "${WORKSPACE}"
        TEST_FILE_PATH = "${WORKSPACE}/test_variables.txt"
        DOCKERHUB_USERNAME = "mijain"
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
                    def testLines = readFile(TEST_FILE_PATH).split(/\r?\n/)
                    for (line in testLines) {
                        def vars = line.trim().split(/\s+/)
                        if (vars.size() < 3) continue
                        
                        def arg1 = vars[0]
                        def arg2 = vars[1]
                        def expectedSum = vars[2].toFloat()
                        
                        def output = bat(script: "docker exec ${CONTAINER_ID} python /app/sum.py ${arg1} ${arg2}", returnStdout: true)
                        def result = output.split('\n')[-1].trim().toFloat()
                        
                        if (Math.abs(result - expectedSum) < 1e-6) {
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
                bat "docker tag sum-app %DOCKERHUB_USERNAME%/sum-app:latest"
                bat "docker push %DOCKERHUB_USERNAME%/sum-app:latest"
            }
        }
    }
    post {
        always {
            script {
                if (CONTAINER_ID?.trim()) {
                    bat "docker stop ${CONTAINER_ID}"
                    bat "docker rm ${CONTAINER_ID}"
                } else {
                    echo "No container to clean up."
                }
            }
        }
    }
}