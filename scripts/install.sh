#!/bin/bash


set -x

SERVICE=$IMAGE

env

# Make sure the host is mounted
if [ ! -d /host/etc -o ! -d /host/proc -o ! -d /host/var/run ]; then
	    echo "Host file system is not mounted at /host" >&2
	        exit 1
fi

# Make sure that we have required directories in the host
for CUR_DIR in /host/${LOGDIR}/${NAME} /host/${DATADIR}/${NAME} /host/${CONFDIR}/${NAME} ; do
    if [ ! -d $CUR_DIR ]; then
        mkdir -p $CUR_DIR
	if [ "$CUR_DIR" == "/host/${CONFDIR}/${NAME}" ] ; then
	    mv -v /insteon_mqtt/config.yaml.example /host/${CONFDIR}/${NAME}/config.yaml
	fi
        chmod 775 $CUR_DIR
	chgrp -R 0 $CUR_DIR
	chmod g+r -R $CUR_DIR
    fi
done    

# Install a udev rule for the insteon PLM
echo 'KERNEL=="ttyUSB?", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", NAME="insteon0", SYMLINK="insteon", GROUP="18", MODE="660"' > /host/etc/udev/rules.d/10-insteon.rules

chroot /host /usr/bin/udevadm control --reload-rules && chroot /host /usr/bin/udevadm trigger

chroot /host /usr/bin/podman create --name ${NAME} --net=host --device /dev/insteon:/dev/insteon,rw --entrypoint /sbin/entrypoint.sh -v ${DATADIR}/${NAME}:/var/lib/insteon_mqtt:z,rw -v ${CONFDIR}/${NAME}:/etc/insteon_mqtt:z,rw -v ${LOGDIR}/${NAME}:/var/log/insteon_mqtt:z,rw ${IMAGE} /bin/start.sh
chroot /host sh -c "/usr/bin/podman generate systemd --restart-policy=always -t 1 ${NAME} > /etc/systemd/system/${NAME}.service && systemctl daemon-reload && systemctl enable ${NAME}"

