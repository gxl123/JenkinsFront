#!/bin/bash

#set -e

BC_NAME=$1
shift
REGISTRY_HOST=docker-registry-default.apps.lab.xkgs.gd.csg.local


EXSISTING_SECRET=$(oc get secret/internal-registry-push-by-builder -o Name 2> /dev/null || true)
if [ -z "$EXSISTING_SECRET" ]; then
	for SECRET_NAME in $(oc get sa/builder -o 'jsonpath={.secrets[*].name}') ; do
		TOKEN_SECRET=$(echo $SECRET_NAME | grep token)
		if [ ! -z "$TOKEN_SECRET" ]; then
			TOKEN=$(oc get secret/$TOKEN_SECRET -o 'jsonpath={.data.token}' | base64 --decode)
			oc create secret docker-registry internal-registry-push-by-builder \
				--docker-server="$REGISTRY_HOST" \
				--docker-username=builder --docker-password="$TOKEN" \
				--docker-email=unused
		fi
	done
fi


oc start-build bc/$BC_NAME --wait=true $*
LATEST=$(oc get bc/$BC_NAME -o 'jsonpath={.status.lastVersion}')

sleep 3

BUILD_RESULT=$(oc get build/$BC_NAME-$LATEST -o 'jsonpath={.status.phase}')
if [ "$BUILD_RESULT" != "Complete" ]; then
	echo "Build result of build/$BC_NAME-$LATEST did not indicate success: $BUILD_RESULT"
	exit 127
fi

DC_IMAGE_NAME=$(oc get bc/$BC_NAME -o 'jsonpath={.spec.output.to.name}')
DIGEST=$(oc get build/$BC_NAME-$LATEST -o 'jsonpath={.status.output.to.imageDigest}')
oc set image dc/$BC_NAME gghqygl=$DC_IMAGE_NAME@$DIGEST

oc rollout status dc/$BC_NAME


