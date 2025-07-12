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
    
    
        stage('NPM dependiencies audit') {
            steps {
                sh '''
                    npm audit --audit-level=critical
                    npm audit fix --force
                '''
            }
        }

        // stage('OWASP Depencies Check') {
        //     steps {
        //         dependencyCheck additionalArguments: '''--scan \'./\'
        //         --out \'./\'
        //         -- noupdate \'./\'
        //         --format \'ALL\'
        //         --prettyPrint''', odcInstallation: 'OWASP-DepCheck-10'
        //     }
        // }
    }
    
}