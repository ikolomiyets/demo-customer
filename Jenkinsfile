version="1.0.0"
repository="ikolomiyets/demo-customer"
tag="latest"
image="${repository}:${version}.${env.BUILD_NUMBER}"
namespace="demo"

podTemplate(label: 'demo-customer-pod', cloud: 'OpenShift', serviceAccount: 'jenkins-sa',
  containers: [
    containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, command: 'cat', privileged: true,
        envVars: [secretEnvVar(key: 'DOCKER_USERNAME', secretName: 'ikolomiyets-docker-hub-credentials', secretKey: 'username'),
    ]),
    containerTemplate(name: 'kubectl', image: 'roffe/kubectl', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'sonarqube', image: 'iktech/sonarqube-scanner', ttyEnabled: true, command: 'cat')
  ],
  volumes: [
    secretVolume(secretName: 'sonar-scanner.properties', mountPath: '/opt/sonar-scanner/conf'),
    secretVolume(secretName: 'ikolomiyets-docker-hub-credentials', mountPath: '/etc/.secret'),
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
  ]) {
    node('demo-customer-pod') {
        stage('Prepare') {
            checkout scm

//            stage('SonarQube Analysis') {
//                container('sonarqube') {
//                  lock(resource: 'demo-customers') {
//                    try {
//                        def scannerHome = tool 'sonarqube-scanner';
//                        withSonarQubeEnv('Sonarqube') {
//                            sh "${scannerHome}/bin/sonar-scanner"
//                        }
//                    } catch (error) {
//                        slackSend color: "danger", message: "Build Failure - ${env.JOB_NAME} build number ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
//                        throw error
//                    }
//                  }
//                }
//            }
        }

//        stage("Quality Gate") {
//            milestone(1)
//            lock(resource: 'demo-customers') {
//                timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
//                    def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
//                    if (qg.status != 'OK') {
//                        slackSend color: "danger", message: "Build Failure Quality gate failure ${qg.status} - ${env.JOB_NAME}:${env.BUILD_NUMBER}"
//                        error "Pipeline aborted due to quality gate failure: ${qg.status}"
//                    } else {
//                        milestone(2)
//                    }
//                }
//            }
//        }

        stage('Build Docker Image') {
            container('docker') {
                sh "docker build -t ${image} ."
                sh 'cat /etc/.secret/password | docker login --password-stdin --username $DOCKER_USERNAME'
                sh "docker push ${image}"
                sh "docker tag ${image} ${repository}:${tag}"
                sh "docker push ${repository}:${tag}"
                milestone(3)
            }
        }

        node('master') {
            stage('Tag Source Code') {
                checkout scm

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

                milestone(4)
            }
        }
        stage('Deploy Latest') {
            container('kubectl') {
                sh "kubectl patch -n ${namespace} deployment demo-customer -p '{\"spec\": { \"template\" : {\"spec\" : {\"containers\" : [{ \"name\" : \"demo-customer\", \"image\" : \"${image}\"}]}}}}'"
                milestone(5)
            }
        }
    }
}
