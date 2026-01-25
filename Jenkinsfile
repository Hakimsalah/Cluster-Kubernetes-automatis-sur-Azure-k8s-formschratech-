pipeline {
    agent any

    stages {
        stage('Terraform - Infra') {
            steps {
                build job: 'terraform-pipeline' 
            }
        }

        stage('CD - Kubernetes Manifests') {
            steps {
                build job: 'cd-manifests-pipeline'
            }
        }

    }

    post {
        success {
            echo "✅ Orchestration complète réussie"
        }
        failure {
            echo "❌ Échec de l’orchestration"
        }
    }
}
