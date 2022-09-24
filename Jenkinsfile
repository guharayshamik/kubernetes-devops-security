pipeline {
  agent any

  stages {
      stage('Build Artifact ') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }  
        stage('Unit Test  - JUnit and Jacoco') {
            steps {
              sh "mvn test"
            }
            // post {
            //   always {
            //     junit 'target/surefire-reports/*.xml'
            //     jacoco execPattern: 'target/jacoco.exec'
            //   }
            // }
        }
        stage('SonarQube test') {
           steps {
             sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=jenkins-pipeline -Dsonar.host.url=http://devsecops-demo-sre.eastus.cloudapp.azure.com:9000 -Dsonar.login=sqp_5d90747570097a93bc30fbf01d8094f5d358a487'
            }
         }    
        // stage('SonarQube - SAST') {
        //     steps {
        //         withSonarQubeEnv('SonarQube') { 
        //           sh "mvn sonar:sonar -Dsonar.projectKey=jenkins-pipeline -Dsonar.host.url=http://devsecops-demo-sre.eastus.cloudapp.azure.com:9000"
        //         }
        //         timeout(time: 2, unit: 'MINUTES') {
        //           script {
        //             // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
        //             // true = set pipeline to UNSTABLE, false = don't 
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        //  }
        //}
         stage('Vulnerability Check - Docker') {
            steps {
              parallel(
                "Dependency Scan": {
                   sh "mvn dependency-check:check"
                },
                "Trivy check": {
                  sh "bash trivy.sh"
                },
                "OPA Tests":{
                  sh 'docker run --rm -v $(pwd):/project openpolicyagent/opa test --policy policy.rigo Dockerfile'
                }
              )
            }
         } 

            // post{
            //   always{
            //     dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            //   }
            // }
          
        stage('Docker Hub stage ') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t shguhara/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push shguhara/numeric-app:""$GIT_COMMIT""'
            }
          }
        }
        stage('Kube deployment - dev') {
            steps {
              withKubeConfig([credentialsId: "kubeconfig"]) {
                sh "sed -i 's#replace#shguhara/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh "kubectl apply -f k8s_deployment_service.yaml"
            }
          }
        } 
    }
    post{
      always{
        junit 'target/surefire-reports/*.xml'
        jacoco execPattern: 'target/jacoco.exec'
        dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      }
    }
}