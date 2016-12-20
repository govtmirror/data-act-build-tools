def usaspending_api = [
    Dev: [
        BRANCH: 'dev',
        HOST: 'dev',
        DOMAIN: '*'
    ],
    Stg: [
        BRANCH: 'stg',
        HOST: 'stg',
        DOMAIN: '52.222.54.147'
    ],
    Prod: [
        BRANCH: 'master',
        HOST: 'prod',
        DOMAIN: 'http://usaspending-api-prod-elb-2008705896.us-gov-west-1.elb.amazonaws.com/'
    ]
]

usaspending_api.each { environment, params ->

    String job_name = environment + '-DSAPI'

    String code_repo =          'https://github.com/fedspendingtransparency/usaspending-api.git'
    String build_tools_repo =   'https://github.com/fedspendingtransparency/data-act-build-tools.git'

    buildFlowJob(job_name + '-Pipeline') {

        scm {
            git {
                remote {
                    url(code_repo)
                    credentials('425f93d2-26fa-4ccc-896d-4c8d84e8903e')
                    branch(params.BRANCH)
                }
            }
        }

        triggers {
            githubPush()
        }

        buildNeedsWorkspace()
        buildFlow('build("' + job_name + '-Deploy")')

        configure { project -> // Slack Notifications
            project / publishers << 'jenkins.plugins.slack.SlackNotifier' {
                authToken('3rw4ujND2zCluJML48r4Vk6G')
                room('#datastore')
                notifySuccess('true')
                notifyNotBuilt('true')
                notifyUnstable('true')
                notifyFailure('true')
            }
        }

    }

    job(job_name + '-Deploy') {

        scm {
            git {
                remote {
                    url(build_tools_repo)
                    credentials('425f93d2-26fa-4ccc-896d-4c8d84e8903e')
                    branch('master')
                }
            }
        }

        steps {

            copyArtifacts('GetConfig') { 
                buildSelector {
                    latestSuccessful(true)
                }
                includePatterns('deployment/hosts')
                flatten()
                fingerprintArtifacts()
            }

            shell('ansible-playbook usaspending-instance-image.yml -i hosts \\\n' +
                    '--private-key "/var/lib/jenkins/ssh_keys/DA-SSHKey-' + params.HOST + '.pem" \\\n' +
                    '--extra-vars "HOST=ds_api_' + params.HOST + ' BRANCH=' + params.BRANCH + 
                    ' DOMAIN=' + params.DOMAIN + '"')

        }

    }

}
