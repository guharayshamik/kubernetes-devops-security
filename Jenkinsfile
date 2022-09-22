pipeline {
  agent any

  stages {
      stage('Build Artifact Demo') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }   
    }
}