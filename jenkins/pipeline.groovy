String giturl = "https://github.com/Gcdata23/101digital.git"
String container_registry_endpoint = "711387138131.dkr.ecr.us-west-2.amazonaws.com/test"
String DOCKER_REGISTRY_CRED_USR = "AWS"
String DOCKER_REGISTRY_CRED_PSW = "eyJwYXlsb2FkIjoicTY4MXUvQXFYNFc0amhrTHoxalJjK2ZRbEFVZG11aFdkbW1JazJ5Z21ZbVVvNjNOMk9PSys0djVFVkJBeUVUMVBMMlFtbm1SanlNemdmZFVKNEs5NHdrSjZ3d051QUthVXp5ZEo2MldZbW5xOU9IY1VRaHJwWVVLYkpYTnVqSlh5VjlYZ2ZsU2xtR08reWRMenhLTFRZOHJOdnFrY28zR0oxTEtLTjNKV05xRXZtMVRrUHR4dFBwcXJvY2ZOSkFZb3JVWnZaUWU1SDNteDViNEtrZ0Mrb3gvRGdtYmwzWnR5VS8xdmY2eEJsempXczQxVjFjVnFvL0FCUDM1c3FrL1RaOVJtRmpMZ3BibFQrNHpWbkNkcjZTNjJGTTJKV2hPc1A2OUVRRzlOY3A3a21Uek9FblJBZ20rTXZ1em5lZ2ptT3E3WkpMbGVIYW9Dc0hxWEF0aWFwWXpMRUpRZWFMUkJmS25wdThjME1IT1VzWk9EdEVSZU9UcXlXSzNGWHRqVWpGVXREZ1VYam1yamhUTHh6SXJISmpKaURWcVREdW1PbmtJc2pra051a3UyS2ZMNHB5dkJ0WjBydDVDY21zb2VLS2JUUnVmOCtMZ3EvNlc5OUNPcUlKNi9rT1Q0K21KeTRVU3BpaGlTdGNBS0g3dGp2dHNzYXRFY3FsRjVLbm5uOWJTSS82N1lnZkYrbWlCOTAvcVhtR1JhTk1qTjREVHVNRGRPbUlzUURpQzRnd2tTTml0TXRNMFRVZkJpaWJFaWtydFd4TmxtTWVrUzhNQ1NVaDYwdUR0NzRTUm0zNmVQUGlzRFF0ZS9GNUVVS2doV3hSQTR0L2VxK1B6eWMzSk5GMC83UllQR2Zkb3VFZGlZQjZpOEdYQ0Zqa3Y1WmREUEJZRE55T2xZdFl4cVNhZkxDQ05jbXMrL29DRHBNQ2kvVTN6KzY1ZmxlL0xaTW1zS1VKdTlFWGxSOEVsZTlNRC82aERwZUU0SXo1ZEI2SU0yaitRRUZlaGdTbVBCNHdsWkdkYkVZZGprZDhGa1hUck9vRnRib3lwQ0RRZmhLajBiUGJ6ZTdCNFN6ZGJoNjdwTHVzWTQrQWlBYzBtcy8vMVdEK3ZIY0dKd3B1UXZNL2lGaFZ6aTlIYmlwOGpqR2h4OVROOVE4QlhRVlE2M0x4T1RibDVIeDJrbHhzRVlPZWNSZHY1NEZ4Wi9ldktYYnlVKy8zaEd3aDlpZUY4NnJtLy9UYjdqOEJSV2tGaUdmdXJHZXpjSjBoWEF3MFVGVWxKNytBWHZ6NlEzZkNSNmEraHdBPT0iLCJkYXRha2V5IjoiQVFFQkFIajZsYzRYSUp3LzdsbjBIYzAwRE1lazZHRXhIQ2JZNFJJcFRNQ0k1OEluVXdBQUFINHdmQVlKS29aSWh2Y05BUWNHb0c4d2JRSUJBREJvQmdrcWhraUc5dzBCQndFd0hnWUpZSVpJQVdVREJBRXVNQkVFRE9aejRtcmFSb3FoMU8xZ2pRSUJFSUE3eEJYQXdUQng3WU02SW41VXlESG1La3paeFFkNzJmNFpDeklKblVRMEdEc043ajRkbDdPZVh4QmNqa1NMWEtReTdxTjhUV0xPUzVLbEwrOD0iLCJ2ZXJzaW9uIjoiMiIsInR5cGUiOiJEQVRBX0tFWSIsImV4cGlyYXRpb24iOjE3MzEzMzc0MDZ9"
pipeline {
    agent none
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 10, unit: 'MINUTES')
        retry(conditions: [agent(), kubernetesAgent(handleNonKubernetes: true), nonresumable()], count: 3)
    }
    parameters {
        string defaultValue: 'develop', description: 'Specify branch to build the project', name: 'branch', trim: true
    }
    stages {
        stage("Clone, package and Build container Image") {
            agent {
                kubernetes {

                    nodeSelector("node=jenkins")
                    yaml """\
                    spec:
                      containers:
                      - name: "jnlp"
                        image: "jenkins/inbound-agent:3273.v4cfe589b_fd83-1"
                        resources:
                          requests:
                            memory: "250Mi"
                            cpu: "1500m"
                          limits:
                            memory: "1024Mi"
                            cpu: "2000m"
                      - name: "buildct"
                        image: "gcr.io/kaniko-project/executor:debug"   
                        command:
                        - /busybox/cat
                        tty: true
                      - name: kubectl
                        image: docker.io/bitnami/kubectl
                        command:
                        - cat
                        tty: true
                        securityContext:
                          runAsUser: 1000
                    """.stripIndent()
                }
            }
            steps {
                container('jnlp') {
                    script {
                        script {
                            sh "git config --global http.sslVerify false"
                            checkout([
                                    $class                           : 'GitSCM',
                                    branches                         : [
                                            [
                                                    name: "*/${env.branch}"
                                            ]
                                    ],
                                    doGenerateSubmoduleConfigurations: false,
                                    extensions                       : [
                                            [
                                                    $class           : 'RelativeTargetDirectory',
                                                    relativeTargetDir: "main"
                                            ]
                                    ],
                                    userRemoteConfigs                : [
                                            [
                                                    url: "${giturl}"
                                            ]
                                    ]
                            ])
                            currentBuild.displayName = "${env.branch}"
                        }

                    }
                }
                container('buildct') {
                    script {
                        dir("main/maxweather"){
                            sh """#!/busybox/sh
                              echo "{\\"auths\\":{\\"${container_registry_endpoint}\\":{\\"username\\":\\"${DOCKER_REGISTRY_CRED_USR}\\",\\"password\\":\\"${DOCKER_REGISTRY_CRED_PSW}\\"}}}" > /kaniko/.docker/config.json
                              /kaniko/executor --context . --skip-tls-verify --dockerfile "Dockerfile" --destination "${container_registry_endpoint}:${env.branch}-${BUILD_NUMBER}"
                            """
                        }
                    }
                }
                container('jnlp') {
                    script {
                        script {
                            echo "Update Container Image"
                            dir("main/k8s-manifest/weatherapp") {
                                def data = readYaml file: "deployment.yaml"
                                echo "read YAML"
                                data.spec.template.spec.containers[0].image = "${container_registry_endpoint}:${env.branch}-${BUILD_NUMBER}"
                                echo "Update ASR prefect-server Image ${container_registry_endpoint}:${env.branch}-${BUILD_NUMBER}"
                                sh "rm -rf deployment.yaml"
                                writeYaml file: "deployment.yaml", data: data
                                sh "cat deployment.yaml"
                            }
                        }
                    }
                }
                container(name: 'kubectl', shell: '/bin/sh') {
                    script {
                        dir("main/k8s-manifest/weatherapp") {
                            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                                sh "echo $KUBECONFIG > /.kube/config"
                                sh "kubectl apply -f deployment.yaml"
                            }
                        }
                    }
                }
            }
        }
    }
}