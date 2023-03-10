pipeline{

    agent any

    environment{
        AWS_DEFAULT_REGION="eu-west-3"
        SKIP="N"
        TERRADESTROY="Y"
        FIRST_DEPLOY="N"
        STATE_BUCKET="cley-eks-tfstate-bucket"
        CLUSTER_NAME="cley-eks"
    }

    stages{
        stage("Create Terraform State Buckets"){
            when{
                environment name:'FIRST_DEPLOY',value:'Y'
                environment name:'TERRADESTROY',value:'N'
                environment name:'SKIP',value:'N'
            }
            steps{
                echo "Check if bucket exists else create bucket phase"
                withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                    sh'''
                    aws s3 mb s3://${STATE_BUCKET}'''
                }
            }
        }
/*        stage('Create Terraform State Bucket') {  
            steps {  
                echo 'Running create bucket phase'
                withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                script {
                    def status = sh(script: "aws s3api head-bucket --bucket ${env.STATE_BUCKET}", returnStatus: true)
                    def create = sh(script: "aws s3api create-bucket --bucket ${env.STATE_BUCKET} --region ${env.AWS_DEFAULT_REGION} --create-bucket-configuration LocationConstraint=${env.AWS_DEFAULT_REGION}", returnStatus: true)
                    try {
                        if (status == 0) { // Check if the bucket exists
                        echo 'Bucket ${STATE_BUCKET} already exists'
                    } 
                    else create() {  // Create the bucket if it does not exist
                        echo 'Bucket ${STATE_BUCKET} created'
                    }
                } catch (err) {
                    echo "Caught: ${err}"
                    currentBuild.result = 'SUCCESS'
             }
        }*/

        stage("Deploy Networking"){
            when{
/*                environment name:'FIRST_DEPLOY',value:'Y' */
                environment name:'TERRADESTROY',value:'N'
                environment name:'SKIP',value:'N'
            }
            stages{
                stage('Validate infra'){
                            steps{
                                withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                                    sh '''
                                    cd networking
                                    terraform init
                                    terraform validate'''
                                }
                            }
                        }
                        stage('apply n/w modules'){
                             
                            steps{
                                withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                                    sh '''
                                    cd networking
                                    terraform plan -out outfile
                                    terraform apply outfile'''
                                }
                            }
                        }
            }
        }

        stage("Deploy Cluster"){
            when{
   /*             environment name:'FIRST_DEPLOY',value:'Y' */
                environment name:'TERRADESTROY',value:'N'
                environment name:'SKIP',value:'N'
            }
            stages{
                stage('Validate infra'){
                            steps{
                                withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                                    sh '''
                                    cd cluster
                                    terraform init
                                    terraform validate'''
                                }
                            }
                        }
                        stage('spin up cluster'){
                             
                            steps{
                                withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                                    sh '''
                                    cd cluster
                                    terraform plan -out outfile
                                    terraform apply outfile'''
                                }
                            }
                        }
            }
        }


        stage("Deploy sample app"){
            when{
                environment name:'FIRST_DEPLOY',value:'Y'
                environment name:'TERRADESTROY',value:'N'
                environment name:'SKIP',value:'N'
            }
            steps{
                withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                    sh"""
                    cd sample_app
                    aws eks update-kubeconfig --name ${env.CLUSTER_NAME} 
                    kubectl apply -f ng.yml
                    """
                    sleep 160
                }
            }
        }

        stage('test kubectl'){
            when{
                environment name:'FIRST_DEPLOY',value:'Y'
                environment name:'TERRADESTROY',value:'N'
                environment name:'SKIP',value:'N'
            }
                steps{
                    withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                        script {
                            sh """
                            cd cluster
                            aws eks update-kubeconfig --name ${env.CLUSTER_NAME} --region ${env.AWS_DEFAULT_REGION}
                            kubectl get pods
                            kubectl get nodes
                            """

                           }
                        }
                }
        }

        /*stage('Notify on Slack'){
             when{
                environment name:'FIRST_DEPLOY',value:'Y'
                environment name:'TERRADESTROY',value:'N'
                environment name:'SKIP',value:'N'
            }
            steps{
                slackSend botUser: true, channel: '<channel_name>', message: "EKS Cluster successfully deployed. Cluster Name: $CLUSTER_NAME", tokenCredentialId: '<token_name>'
            }
        }*/



        stage("Run Destroy"){

            when{
                environment name:'TERRADESTROY',value:'Y'
            }
            stages{

                stage("Destroy eks cluster"){
                    steps{
                        withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                            sh '''
                            cd cluster
                            terraform init
                            terraform destroy -auto-approve
                            '''
                        }
                    }
                }

                stage("Destroy n/w infra"){
                    steps{
                        withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                            sh '''
                            cd networking
                            terraform init
                            terraform destroy -auto-approve
                            '''
                        }
                    }
                }

                stage("Destroy state bucket"){
                    steps{
                        withAWS(credentials: '39725218-cd8f-42a5-8857-c434967b37f5', region: "${env.AWS_DEFAULT_REGION}") {
                            script {
                                sh(returnStdout: true, script: "aws s3 rb s3://'${env.STATE_BUCKET}' --force").trim()                    
                            }
                        }
                    }
                }

                //next steps


            }

        }


        




    }

    post { 
        always { 
            cleanWs()
        }
    }





}