podTemplate(label: 'demo-customer-pod', cloud: 'OpenShift', serviceAccount: 'jenkins-sa',
  containers: [
    containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, command: 'cat', privileged: true),
    containerTemplate(name: 'sonarqube', image: 'iktech/sonarqube-scanner', ttyEnabled: true, command: 'cat')
  ],
  volumes: [
    secretVolume(secretName: 'sonar-scanner.properties', mountPath: '/opt/sonar-scanner/conf'),
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock:Z')
  ]) {
    node('demo-customer-pod') {
        stage('Prepare') {
            checkout scm

            stage('SonarQube Analysis') {
                container('sonarqube') {
                    try {
                        def scannerHome = tool 'sonarqube-scanner';
                        withSonarQubeEnv('Sonarqube') {
                            sh "${scannerHome}/bin/sonar-scanner"
                        }
                    } catch (error) {
                        slackSend color: "danger", message: "Build Failure - ${env.JOB_NAME} build number ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                        throw error
                    }
                }
            }

        }

        stage("Quality Gate") {
                timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
                def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
                if (qg.status != 'OK') {
                    slackSend color: "danger", message: "Build Failure Quality gate failure ${qg.status} - ${env.JOB_NAME}:${env.BUILD_NUMBER}"
                    error "Pipeline aborted due to quality gate failure: ${qg.status}"
                }
            }
        }

        stage('Build Docker Image') {
            container('docker') {
                input 'What?'
                sh 'docker build -t docker-registry.default.svc:5000/demo/demo-customer .'
            }
        }
    }
}
