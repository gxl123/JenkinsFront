def OCP_OBJ_NAME = "gghqygl-backend"
//$BUILD_NUMBER为Jenkins构建序号
def IMAGE_TAG =  "1.0.$BUILD_NUMBER"

node ('maven'){
    stage('Checkout') {
        git url: "git@172.31.0.4:emp/be-csgit-project-management.git", branch: "master", credentialsId: 'devops-git'
    }
    
    stage("Maven Package"){
        sh "mvn clean package -DskipTests=true -s ./settings.xml"
    }
    
    stage("Run tests"){
        sh "mvn test -s ./settings.xml"
    }

    stage("build image"){


        sh """
         oc project gghqygl-qa

         #设置BC应用镜像输出路径
         IMAGE_NAME=\$(oc get bc/$OCP_OBJ_NAME -o 'jsonpath={.spec.output.to.name}' | cut -d ':' -f 1)
         PATCH_JSON="{\\"spec\\":{\\"output\\":{\\"to\\":{\\"name\\":\\"\$IMAGE_NAME:$IMAGE_TAG\\"}}}}"
         oc patch bc/$OCP_OBJ_NAME -p "\$PATCH_JSON"
         sleep 1

         #start-build 执行bc,并检查执行结果
         oc start-build bc/$OCP_OBJ_NAME --from-file=target/pms-0.0.1-SNAPSHOT.jar --wait=true --follow
         
         LATEST=\$(oc get bc/$OCP_OBJ_NAME -o 'jsonpath={.status.lastVersion}')
         oc label build/$OCP_OBJ_NAME-\$LATEST buildNumber=$BUILD_NUMBER --overwrite
         sleep 1
         BUILD_RESULT=\$(oc get build/$OCP_OBJ_NAME-\$LATEST -o 'jsonpath={.status.phase}')
         if [ "\$BUILD_RESULT" != "Complete" ]; then
         	echo "Build result of build/$OCP_OBJ_NAME-\$LATEST did not indicate success: \$BUILD_RESULT"
         	exit 127
         fi
         """
    }

    stage("deploy image"){
        sh """
        LATEST=\$(oc get bc/$OCP_OBJ_NAME -o 'jsonpath={.status.lastVersion}')
        DC_IMAGE_NAME=\$(oc get bc/$OCP_OBJ_NAME -o 'jsonpath={.spec.output.to.name}')
        DIGEST=\$(oc get build/$OCP_OBJ_NAME-\$LATEST -o 'jsonpath={.status.output.to.imageDigest}')

        #给dc设置image拉取路径
        oc set image dc/$OCP_OBJ_NAME gghqygl=\$DC_IMAGE_NAME@\$DIGEST
        oc rollout status dc/$OCP_OBJ_NAME

        #给rc加入label-commitId，以便关联发布版本与git提交对应关系
        LATEST_commitId=\$(git rev-parse --short HEAD)
        LATEST_VERSION=\$(oc get dc/$OCP_OBJ_NAME -o 'jsonpath={.status.latestVersion}')
        LATEST_RC=$OCP_OBJ_NAME-\$LATEST_VERSION
        oc label rc/\$LATEST_RC commitId=\$LATEST_commitId buildNumber=$BUILD_NUMBER --overwrite
        """
    }

}
