#!/bin/bash

set +x

OS_RELEASE=${OS_RELEASE:-$(grep VERSION_ID /etc/os-release | cut -d '=' -f 2)}
OS_IMAGE=${OS_IMAGE:-"registry.fedoraproject.org/fedora:${OS_RELEASE}"}
BUILD_ID=${BUILD_ID:-`date +%s`}
BUILD_ARCH=${BUILD_ARCH:-`uname -m`}
PUSHREG=${PUSHREG:-""}

echo podman build --build-arg OS_RELEASE=${OS_RELEASE} --build-arg OS_IMAGE=${OS_IMAGE} -t ${BUILD_ARCH}/insteonmqtt:${BUILD_ID} -f Containerfile.Fedora
podman build --build-arg OS_RELEASE=${OS_RELEASE} --build-arg OS_IMAGE=${OS_IMAGE} -t ${BUILD_ARCH}/insteonmqtt:${BUILD_ID} -f Containerfile.Fedora


if [ $? -eq 0 ]; then
  echo  podman tag ${BUILD_ARCH}/insteonmqtt:${BUILD_ID} ${BUILD_ARCH}/insteonmqtt:latest
  podman tag ${BUILD_ARCH}/insteonmqtt:${BUILD_ID} ${BUILD_ARCH}/insteonmqtt:latest

  if [ ! -z "${PUSHREG}" ]; then
    echo podman tag ${BUILD_ARCH}/insteonmqtt:${BUILD_ID} ${PUSHREG}/${BUILD_ARCH}/insteonmqtt:${BUILD_ID}
    podman tag ${BUILD_ARCH}/insteonmqtt:${BUILD_ID} ${PUSHREG}/${BUILD_ARCH}/insteonmqtt:${BUILD_ID}
    echo podman push ${PUSHREG}/${BUILD_ARCH}/insteonmqtt:${BUILD_ID}
    podman push ${PUSHREG}/${BUILD_ARCH}/insteonmqtt:${BUILD_ID}
    echo podman tag ${BUILD_ARCH}/insteonmqtt:${BUILD_ID} ${PUSHREG}/${BUILD_ARCH}/insteonmqtt:latest
    podman tag ${BUILD_ARCH}/insteonmqtt:${BUILD_ID} ${PUSHREG}/${BUILD_ARCH}/insteonmqtt:latest
    echo podman push ${PUSHREG}/${BUILD_ARCH}/insteonmqtt:latest
    podman push ${PUSHREG}/${BUILD_ARCH}/insteonmqtt:latest
  fi
fi

