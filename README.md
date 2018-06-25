# vppb

Vagrant/Poudriere Package Builder

Launch a FreeBSD vagrant VM, install Poudriere, then build packages of the ports given during the configure stage.

## Usage

```bash
./build.sh configure
./build.sh
```

## Requirements

* Vagrant
* VirtualBox
* OpenSSL (or compatible CLI replacement)
* curl

## Caveats

Most of the interesting options are set as variables at the top of [build.sh](build.sh). In the future, it'd be nice to make these passable on the command line, or retrievable from a config file.

The amount of RAM given to the VM is hard-coded inside of [Vagrantfile](Vagrantfile).
