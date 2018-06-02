

node('metabox') {

    stage('sanity check') {
       
        sh 'whoami'

        // env set
        sh 'printenv | sort'

        // ruby
        sh 'which ruby'
        sh 'ruby --version'

        sh 'which gem'
        sh 'gem --version'
        sh 'gem list | sort'

        // git
        sh 'which git'
        sh 'git --version'

        // metabox
        sh 'which metabox'
        sh 'metabox version'
    }
}