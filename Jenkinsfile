pipeline {
    agent {
        label 'Jenkins-Agent'
    }
    tools {
        nodejs 'nodejs-22.6.0'  
    }

    stages {
        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }
    
    
        stage('NPM Dependiencies audit') {
            steps {
                sh '''
                    npm audit --audit-level=critical
                '''
            }
        }

        stage('OWASP Depencies Check') {
            steps {
                dependencyCheck additionalArguments: '''--scan package.json
                --format ALL  --noupdate''', odcInstallation: 'OWASP-DepCheck-10'

                publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './', reportFiles: 'dependency-check-jenkins.html', reportName: 'Dependency Check HTML Report', reportTitles: '', useWrapperFileDirectly: true])
            }
        }

        stage('Docker Image Build') {
            steps {
                sh '''
                    docker build -t soewailin/nodejs-todolist:$GIT_COMMIT .
                '''
            }
        }

        stage('Trivy Scan Docker Image') {
            steps {
                sh '''
                    trivy image soewailin/nodejs-todolist:$GIT_COMMIT \
                        --severity LOW,MEDIUM \
                        --exit-code 0 \
                        --quiet \
                        --format json -o trivy-image-Medium.json

                    trivy image soewailin/nodejs-todolist:$GIT_COMMIT \
                        --severity HIGH \
                        --exit-code 0 \
                        --quiet \
                        --format json -o trivy-image-High.json
                '''
            }

            post {
                always {
                    sh '''
                        trivy convert \
                            --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                            -o trivy-image-Medium.html trivy-image-Medium.json

                        trivy convert \
                            --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
                            -o trivy-image-Medium.xml trivy-image-Medium.json

                        trivy convert \
                            --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                            -o trivy-image-High.html trivy-image-High.json

                        trivy convert \
                            --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
                            -o trivy-image-High.xml trivy-image-High.json
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub-creds', url: "") {
                    sh '''
                        docker push soewailin/nodejs-todolist:$GIT_COMMIT 
                    '''
                }
            }
        }
    }
    
}