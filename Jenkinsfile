version="1.0.0"

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
                } else {
                    milestone()
                }
            }
        }

        stage('Build Docker Image') {
            container('docker') {
                sh "docker build -t docker-registry.default.svc:5000/demo/demo-customer:${version}.${env.BUILD_NUMBER} ."
                sh 'cat /var/run/secrets/kubernetes.io/serviceaccount/token | docker login --password-stdin --username jenkins-sa docker-registry.default.svc:5000'
                sh "docker push docker-registry.default.svc:5000/demo/demo-customer:${version}.${env.BUILD_NUMBER}"
                milestone()
            }
        }

        stage('Tag Source Code') {
            def repositoryCommitterEmail = "jenkins@iktech.io"
            def repositoryCommitterUsername = "jenkinsCI"
            values = version.tokenize(".")

            sh "git config user.email ${repositoryCommitterEmail}"
            sh "git config user.name '${repositoryCommitterUsername}'"
            sh "git tag -d v${values[0]} || true"
            sh "git push origin :refs/tags/v${values[0]}"
            sh "git tag -d v${values[0]}.${values[1]} || true"
            sh "git push origin :refs/tags/v${values[0]}.${values[1]}"
            sh "git tag -d v${version} || true"
            sh "git push origin :refs/tags/v${version}"

            sh "git tag -fa v${values[0]} -m \"passed CI\""
            sh "git tag -fa v${values[0]}.${values[1]} -m \"passed CI\""
            sh "git tag -fa v${version} -m \"passed CI\""
            sh "git tag -a v${version}.${env.BUILD_NUMBER} -m \"passed CI\""
            sh "git push -f --tags"

            milestone()
        }
    }
}
