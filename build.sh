#!/bin/sh

JAILNAME=vpb
FBSDTARGET=11.1-RELEASE
FBSDARCH=amd64
PORTSMETHOD=portsnap
ARTIFACTS=artifacts
WORK=work
SSHCONFIG=${WORK}/ssh_config

# Vagrant refuses to do anything if provisioners don't exist (even `vagrant destroy` doesn't work)
mkdir -p ${WORK}/options
touch ${WORK}/ports.list

# When build.sh is called by a human
if [ "$1" = "" ]; then
  if [ ! -s ${WORK}/ports.list ]; then
    echo "Can't find ${WORK}/ports.list. Run '$0 configure' first."
    exit 1
  fi

  if [ ! -e ${WORK}/options ]; then
    echo "Can't find ${WORK}/options. Run '$0 configure' first."
    exit 1
  fi

  vagrant up --no-provision
  if [ $? != 0 ]; then
    echo 'Build failed!'
    exit 1
  fi

  vagrant provision
  if [ $? != 0 ]; then
    echo 'Build failed!'
    exit 1
  fi

  echo '==> Build complete!'
  echo "==> Copying artifacts to ${ARTIFACTS}"
  vagrant ssh-config --host poudriere > $SSHCONFIG

  if [ ! -e "${ARTIFACTS}" ]; then
    mkdir ${ARTIFACTS}
  fi

  scp -F $SSHCONFIG "poudriere:/usr/local/poudriere/data/packages/${JAILNAME}-default/All/*" ${ARTIFACTS}/ &>/dev/null
  if [ $? != 0 ]; then
    echo 'Copying artifacts failed!'
    exit 1
  fi

  echo '==> Done!'
  echo
  echo "Artifacts are in: ${ARTIFACTS}"
  echo "Don't forget to run 'vagrant destroy' if you're done with the build VM."

# Clean up
elif [ "$1" = "clean" ]; then
  read -p "This will delete the artifacts directory and the vagrant VM. Hit enter to continue." OK
  rm -rf $SSHCONFIG artifacts
  vagrant destroy -f

elif [ "$1" = "configure" ]; then
  > ${WORK}/ports.list
  echo "Enter the ports you want to build, one per line. Enter a blank line to stop."
  while read line; do
    if [ -z "$line" ]; then break; fi
    echo $line >> ${WORK}/ports.list
  done

  vagrant up --provision-with portsfile,installonly
  if [ $? != 0 ]; then
    echo 'Configuration failed!'
    exit 1
  fi

  vagrant ssh -- -t "sudo poudriere options -f /usr/local/etc/poudriere.d/ports.list"
  if [ $? != 0 ]; then
    echo 'Configuration failed!'
    exit 1
  fi

  vagrant ssh-config --host poudriere > $SSHCONFIG
  rm -rf ${WORK}/options/*
  scp -r -F $SSHCONFIG "poudriere:/usr/local/etc/poudriere.d/options/*" ${WORK}/options/ &>/dev/null

  echo "==> Configuration done. Ready to run $0."

elif [ "$1" = "installonly" ]; then
  env ASSUME_ALWAYS_YES=YES pkg install ports-mgmt/poudriere
  poudriere ports -c -m $PORTSMETHOD
  mv /tmp/ports.list /usr/local/etc/poudriere.d/ports.list
  rm -rf /usr/local/etc/poudriere.d/options/*

# When build.sh is called by vagrant ("poudriere" matches the arg to this script in Vagrantfile)
elif [ "$1" = "poudriere" ]; then
  mkdir -p /usr/ports/distfiles
  poudriere jail -c -j $JAILNAME -v $FBSDTARGET -a $FBSDARCH
  echo "WITH_PKGNG=yes" >> /usr/local/etc/poudriere.d/make.conf
  mv /tmp/options /usr/local/etc/poudriere.d/
  poudriere bulk -j $JAILNAME -f /usr/local/etc/poudriere.d/ports.list

fi
