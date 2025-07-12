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
                    npm audit || true  // Continue even if vulnerabilities are found
                    npm audit fix || true
                '''
            }
        }

        stage('OWASP Depencies Check') {
            steps {
                dependencyCheck additionalArguments: '''--scan package.json
                --format XML''', odcInstallation: 'OWASP-DepCheck-10'
            }
        }
    }
    
}