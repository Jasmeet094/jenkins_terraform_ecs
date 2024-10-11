
def aws_testStagingAppWebAppJob = job('aws_test Staging App Web App - TEST') {
    description('The aws_test 1.0 (stag-app) website')
    label('aws2') 
    scm {
        git {
            remote {
                url('git@github.com:Jasmeet94/my-website.git')
                branch('origin/stag-app')
            }
            extensions {
                cleanBeforeCheckout()
                cleanAfterCheckout()
                cloneOptions {
                    timeout(20)
                }
            }
        }
    }
    triggers {
        scm('H/2 * * * *')
    }
    steps {
        batchFile('''
          cd aws_testWeb
          type Web-Template.config|repl "\\bDATASOURCE\\b" "staging.cnymgtprjppc.us-east-1.rds.amazonaws.com" >Web-Template.config.new
          move Web-Template.config.new Web-Template.config  
          type Web-Template.config|repl "\\bINTITIALCATALOG\\b" "aws_test" >Web-Template.config.new
          move Web-Template.config.new Web-Template.config  
          type Web-Template.config|repl "\\bUSERNAME\\b" "cgweb" >Web-Template.config.new
          move Web-Template.config.new Web-Template.config  
          type Web-Template.config|repl "\\bPASSWORD\\b" "cgweb" >Web-Template.config.new
          move Web-Template.config.new Web-Template.config  
          copy Web-Template.config web.config
        '''.stripIndent())

        msbuild {
            msBuildName('MSBuild 17')
            msBuildFile('')
            cmdLineArgs('build.xml')
            buildVariablesAsProperties(true)
            continueOnBuildFailure(true)
            unstableIfWarnings(false)
            doNotUseChcpCommand(true)
        }

        batchFile('''
          REM ---- WEBSITE ----
          pushd aws_testWeb\\Build\\_PublishedWebsites\\aws_testWeb
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:runCommand="iisreset /stop",waitInterval=5000 -dest:auto,computerName=
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:contentPath="%cd%" -dest:contentPath=caregard-website,computerName=
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:runCommand="iisreset /start",waitInterval=5000 -dest:auto,computerName=
          popd   
          REM ---- DATABASE ----
          REM -- commented out as aws_test 1.0 database work is on hold while 2.0 rollout is in progress
        '''.stripIndent())
    }
    publishers {
        flowdock('9b6c376345f5553986f7544b6d928bc1') {
            unstable()
            success()
            aborted()
            failure()
            fixed()
            notBuilt()
        }
    }
}

def aws_testStagingMyWebAppJob = job('aws_test Staging My Web App - TEST') {
    description('The aws_test Staging My Web App')
    label('aws2') 
    scm {
        git {
            remote {
                url('git@github.com:Jasmeet94/aws_test-trm-2-0.git')
                branch('origin/stag-my')
            }
            extensions {
                cleanBeforeCheckout()
                cleanAfterCheckout()
                cloneOptions {
                    timeout(20)
                }
            }
        }
    }
    triggers {
        scm('H/2 * * * *')
    }
    steps {
        batchFile('''
          pushd aws_test.Web
          powershell -noprofile -file Replace-Contents.ps1 Web.Staging.config "{RSRptViewerUser}" "cgweb"
          powershell -noprofile -file Replace-Contents.ps1 Web.Staging.config "{RSRptViewerPwd}" "AeXGkiUF71Oi"
          powershell -noprofile -file Replace-Contents.ps1 Web.Staging.config "{CWSSvcUser}" "aws_test"
          popd
        '''.stripIndent())

        msbuild {
            msBuildName('MSBuild 17')
            msBuildFile('')
            cmdLineArgs('build.xml /t:Build /p:Configuration=Staging')
            buildVariablesAsProperties(true)
            continueOnBuildFailure(true)
            unstableIfWarnings(false)
            doNotUseChcpCommand(true)
        }

        batchFile('''
          REM ---- WEBSITE ----
          pushd aws_test.Web\\Build
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:runCommand="iisreset /stop",waitInterval=5000 -dest:auto,computerName=
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:contentPath="%cd%" -dest:contentPath=aws_test-website,computerName=
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:runCommand="iisreset /start",waitInterval=5000 -dest:auto,computerName=
          popd
        '''.stripIndent())
    }
}

def aws_testProductionAppWebApp = job('aws_test Production App Web App (LB) - TEST') {
    description('This is the build and deploy for aws_test App (1.0) production to the load balanced aws_test web servers.')
    label('aws2') 
    scm {
        git {
            remote {
                url('git@github.com:afgtechnologies/aws_test-website.git')
                branch('origin/master')
            }
            extensions {
                cleanBeforeCheckout()
                cleanAfterCheckout()
                cloneOptions {
                    timeout(20)
                }
            }
        }
    }
    triggers {
        scm('H/2 * * * *')
    }
    steps {
        batchFile('''
          cd aws_testWeb
          type Web-Template.config|repl "\\bDATASOURCE\\b" "prod-aws_test.cnymgtprjppc.us-east-1.rds.amazonaws.com" >Web-Template.config.new
          move Web-Template.config.new Web-Template.config  
          type Web-Template.config|repl "\\bINTITIALCATALOG\\b" "aws_test" >Web-Template.config.new
          move Web-Template.config.new Web-Template.config  
          type Web-Template.config|repl "\\bUSERNAME\\b" "cgweb" >Web-Template.config.new
          move Web-Template.config.new Web-Template.config  
          copy Web-Template.config web.config
        '''.stripIndent())

        msbuild {
            msBuildName('MSBuild 17')
            msBuildFile('')
            cmdLineArgs('build.xml')
            buildVariablesAsProperties(true)
            continueOnBuildFailure(true)
            unstableIfWarnings(false)
            doNotUseChcpCommand(true)
        }

        batchFile('''
          REM ---- WEBSITE ----
          pushd aws_testWeb\\Build\\_PublishedWebsites\\aws_testWeb
          REM 172.31.97.186 prod-app1
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:runCommand="iisreset /stop",waitInterval=5000 -dest:auto,computerName=
          REM 172.31.65.193 prod-app2
          popd
          REM ---- DATABASE ----
          @powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { $OctopusEnvironmentName='prod'; $DatabaseServer='prod-aws_test.cnymgtprjppc.us-east-1.rds.amazonaws
        '''.stripIndent())
    }
    publishers {
        flowdock('9b6c376345f5553986f7544b6d928bc1') {
            unstable()
            success()
            aborted()
            failure()
            fixed()
            notBuilt()
        }
    }
}

def aws_testProductionAppWebApp2 = job('aws_test Production App Web App2 (LB) - TEST') {
    description('')
    label('aws2') 
    scm {
        git {
            remote {
                url('git@github.com:afgtechnologies/aws_test-trm-2-0.git')
                branch('origin/master')
            }
            extensions {
                cleanBeforeCheckout()
                cleanAfterCheckout()
                cloneOptions {
                    timeout(20)
                }
            }
        }
    }
    triggers {
        scm('H/2 * * * *')
    }
    steps {
        batchFile('''
          pushd aws_test.Web

          popd
        '''.stripIndent())
        
        msbuild {
            msBuildName('MSBuild 17')
            msBuildFile('')
            cmdLineArgs('build.xml /t:Build /p:Configuration=Release')
            buildVariablesAsProperties(true)
            continueOnBuildFailure(true)
            unstableIfWarnings(false)
            doNotUseChcpCommand(true)
        }

        batchFile('''
          REM ---- WEBSITE ----
          pushd aws_test.Web\\Build
          REM 172.31.97.186 prod-app1
          REM -- 1.0 stops IIS, but we're not doing that here yet...
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:runCommand="c:\\windows\\system32\\inetsrv\\appcmd.exe stop apppool aws_test-website",waitInterval=5000 -dest:auto,computerName=http://172.31.97.186/MsDeployAgentService,userName=Administrator,password=K!f*!9wK%%z?T
          REM -- restart IIS (not doing it here yet)
          REM 172.31.65.193 prod-app2
          "C:\\Program Files\\IIS\\Microsoft Web Deploy V3\\msdeploy.exe" -verb:sync -source:runCommand="c:\\windows\\system32\\inetsrv\\appcmd.exe start apppool aws_test-website",waitInterval=5000 -dest:auto,computerName=http://172.31.65.193/MsDeployAgentService,userName=Administrator,password=K!f*!9wK%%z?T
          popd
        '''.stripIndent())
        
    }
}
