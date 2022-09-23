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
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }
        stage('Docker Hub stage ') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t shguhara/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push shguhara/numeric-app:""$GIT_COMMIT""'
            }
          }
        }   
    }
}