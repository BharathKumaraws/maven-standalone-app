node {
    
    def mavenHome = tool name : 'maven-3.9.16' 

    try {

        stage('git checkout'){
        git branch: 'devlopment', url: 'https://github.com/BharathKumaraws/maven-standalone-app.git'

        }

        stage('git clean') {
        sh "${mavenHome}/bin/mvn clean"
        }

        stage('git package'){
        sh "${mavenHome}/bin/mvn package"
        }

        stage('git sonar report'){
        sh "${mavenHome}/bin/mvn sonar:sonar"
        }

        stage('Deploy to Nexus'){
        sh "${mavenHome}/bin/mvn deploy"
        }

        stage('Deploy to tomcat') {
        sh """
        curl -u admin:Bharath \
        --upload-file /var/lib/jenkins/workspace/Scriptedwaypipeline/target/maven-web-application.war \
        "http://54.198.192.214:8080//manager/text/deploy?path=/maven-web-application&update=true"
        """
        }

    }

    catch (e) {
        currentBuild.result="FAILED"
        throw e
    }

    finally {
        notifyBuild(currentBuild.result)
    }

  
}

def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESS'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"

  // Override default values based on build status
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

  // Send notifications
  slackSend (color: colorCode, message: summary)
}
