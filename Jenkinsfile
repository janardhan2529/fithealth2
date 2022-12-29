pipeline{
    agent{
        label 'jenkinsslave2'
    }
    environment{
        AWS_ACCESS_KEY_ID=credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY=credentials('AWS_SECRET_ACCESS_KEY')
    }
    options{
        timestamps()
    }
    tools{
        maven '3.8.6'
        terraform '21207'
    }
    triggers{
        
       pollSCM('H/1 * * * *')
    }
    stages{
        stage('checkout'){
            steps{
            git credentialsId: 'gitclone', url: 'https://github.com/janardhan2529/fithealth2.git'
            
        }
        }
        stage('test'){
            steps{
                sh 'mvn --batch-mode clean test'
            }
        }
        stage('infra'){
            steps{
            sh '''
               terraform -chdir=/u01/jenkins/workspace/fithealth/src/main/terraform/global/ init 
               terraform -chdir=/u01/jenkins/workspace/fithealth/src/main/terraform/global/ apply -target null_resource.copy -auto-approve
            '''
            }
        }
    stage('s/w config'){
        steps{
            sh '''
            sudo chmod u+x /u01/jenkins/workspace/fithealth/src/main/config/sshconnection.sh
            sudo chmod 600 /u01/jenkins/workspace/fithealth/src/main/terraform/global/keys/jana
              /u01/jenkins/workspace/fithealth/src/main/config/sshconnection.sh
            '''
        }
    }
        stage('build'){
            steps{
                sh'''
                
                mvn -f /u01/jenkins/workspace/fithealth/pom.xml clean verify
                '''
            }
        }
        stage('deploy'){
            steps{
            sh'''
            sudo chmod u+x /u01/jenkins/workspace/fithealth/src/main/config/deploy.sh
             /u01/jenkins/workspace/fithealth/src/main/config/deploy.sh
            '''
            }
        }
    }
}
