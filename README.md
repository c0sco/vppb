# vppb

Vagrant/Poudriere Package Builder

Launch a FreeBSD vagrant VM, install Poudriere, then build packages of the ports given during the configure stage.

## Usage

```bash
./build.sh configure
./build.sh
```

## Caveats

This system does not check if the ports you specify exist. Make sure the ports you enter during the configure stage are typed in properly.
