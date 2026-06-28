pipeline {
  agent any 

  tools {
    maven "maven-3.9.16"
  }

  stages 
  {
    stage('git checkout') 
    {
      steps 
      {

        git branch: 'devlopment', url: 'https://github.com/BharathKumaraws/maven-standalone-app.git'

      }
    }
    stage("Clean and Build")
    {
      steps 
      {
        sh "mvn clean package"
      }
    }
    stage('Deploy to sonar')
    {
      steps
      {
        sh  "mvn sonar:sonar"
      }
    }
    stage('Depoy to Nexus')
    {
      steps
      {
        sh "mvn deploy"
      }
    }

    stage('Deploy to Tomcat')
    {
      steps 
      {

        echo "Deploying WAR file using curl..."

        sh """
            curl -u admin:Bharath \
            --upload-file /var/lib/jenkins/workspace/DeclarativePipeline/target/maven-web-application.war \
            "http://54.226.20.81:8080/manager/text/deploy?path=/maven-web-application&update=true"
        """


      }
    }

}

post 
{
  success 
  {
    notifyBuild(currentBuild.result)
  }
  failure 
  {
    notifyBuild(currentBuild.result)
  }
}

}
def notifyBuild(String buildStatus ='STARTED'){
  buildStatus = buildStatus ?: 'SUCCESS'

  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"

  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESS') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  slackSend  (color: colorCode, message: summary, channel: '#jio-dev')
}
