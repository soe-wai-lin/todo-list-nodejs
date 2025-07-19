pipeline {
    agent any 
    // agent {
    //     label 'Jenkins-Agent'
    // }
    tools {
        nodejs 'nodejs-18.20.8'    
    }

    environment {
        SONAR_SCANNER = tool 'sonarqube-scanner-6.1.0';
        GITHUB_TOKEN = credentials('jenkin-push-github')
        REPO_URL = 'https://github.com/soe-wai-lin/argo-nodejs-todo.git'
        REPO_NAME = 'argo-nodejs-todo'
        FEATURE_BRANCH = "feature-${BUILD_ID}"
    }

    stages {
        stage('Install dependencies') {
            steps {
                sh '''
                    npm -v
                    node -v
                    npm install
                '''   
            }
        }
   
    
        stage('NPM Dependiencies Audit') {
            steps {
                sh '''
                    npm audit --audit-level=critical
                '''
            }
        }

        stage('SonarQube') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') {
                        sh '''
                            $SONAR_SCANNER/bin/sonar-scanner \
                                -Dsonar.projectKey=nodejs \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=http://175.41.181.17:9000 \
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'jenkins-sonarqube-token'
                }
            }
        }

        // stage('OWASP Depencies Check') {
        //     steps {
        //         dependencyCheck additionalArguments: '''--scan package.json
        //         --format ALL''', odcInstallation: 'OWASP-DepCheck-10'

        //         publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './', reportFiles: 'dependency-check-jenkins.html', reportName: 'Dependency Check HTML Report', reportTitles: '', useWrapperFileDirectly: true])

        //         junit allowEmptyResults: true, keepProperties: true, testResults: 'dependency-check-junit.xml'
        //     }
        // }

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
        stage('K8s Image Update') {
            steps {
                sh '''
                    rm -rf argo-nodejs-todo
                    git clone -b main https://github.com/soe-wai-lin/argo-nodejs-todo.git
                    cd argo-nodejs-todo

                    git checkout -b feature-$BUILD_ID

                    sed -i "s#soewailin/nodejs-todolist:.*#soewailin/nodejs-todolist:$GIT_COMMIT#g" deployment.yaml
                    cat deployment.yaml

                    git config user.email "jenkin@gmail.com"
                    git config user.name "Jenkins CI"

                    git remote set-url origin https://$GITHUB_TOKEN@github.com/soe-wai-lin/argo-nodejs-todo.git

                    git add deployment.yaml
                    git commit -m "Update Docker image to $GIT_COMMIT"

                    git pull origin feature-$BUILD_ID --rebase || true
                    git push origin feature-$BUILD_ID
                '''
            }
        }

        stage('Create Pull Request') {
            steps {
                sh '''
                    cd ${REPO_NAME}
                    gh pr create --base main --head ${FEATURE_BRANCH} --title "Auto PR from Jenkins" --body "This PR was created automatically by Jenkins pipeline."
                    echo $?
                    set -e
                '''
            }
            
        }
}
}
 