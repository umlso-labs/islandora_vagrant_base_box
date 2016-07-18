## Introduction

This is a base box for [Islandora Vagrant](https://github.com/umlso-labs/islandora_vagrant), and an export box lives on [atlas](https://atlas.hashicorp.com/zrrm74/boxes/islandora-bb-umlso).

By default the virtual machine that is built uses 3GB of RAM. Your host machine will need to be able to support that. You can override the CPU and RAM allocation by creating `ISLANDORA_VAGRANT_CPUS` and `ISLANDORA_VAGRANT_MEMORY` environment variables and setting the values. For example, on an Ubuntu host you could add to `~/.bashrc`:

```bash
export ISLANDORA_VAGRANT_CPUS=4
export ISLANDORA_VAGRANT_MEMORY=4096
```

N.B. This virtual machine **should not** be used in production.

## Requirements

1. [VirtualBox](https://www.virtualbox.org/)
2. [Vagrant](http://www.vagrantup.com/)

## Use

1. `git clone https://github.com/umlso-labs/islandora_vagrant_base_box`
2. `cd islandora_vagrant`
3. `vagrant up`

## Connect

You can connect to the machine via the browser at [http://localhost:8000](http://localhost:8000).

The default Drupal login details are:
  - username: admin
  - password: islandora

MySQL:
  - username: root
  - password: islandora

Tomcat Manager:
  - username: islandora
  - password: islandora

Fedora:
  - username: fedoraAdmin
  - password: fedoraAdmin

GSearch:
  - username: fgsAdmin
  - password: fgsAdmin

ssh, scp, rsync:
  - username: vagrant
  - password: vagrant
  - Examples
    - `ssh -p 2222 vagrant@localhost`
    - `scp -P 2222 somefile.txt vagrant@localhost:/destination/path`
    - `rsync --rsh='ssh -p2222' -av somedir vagrant@localhost:/tmp`

## Environment
### (Note: these are specific to this fork) 
- Ubuntu 14.04
- Drupal 7.39
- MySQL 5.5.44
- Apache 2.4.7-1ubuntu4.5
- Tomcat 6.0.39-1 
- Solr 3.6.2
- Fedora 3.6.2 
- GSearch HEAD
- PHP 5.5.9 
- Java 6 (Oracle)

## Customization

If you'd like to add your own customization script (to install additional modules, call other scripts, etc.), you can create a `custom.sh` file in the project's `scripts` directory. When that file is present, Vagrant will run it after all the other provisioning scripts have been run.

### Custom base box
To create a custom base box to use with Atlas (e.g., if you need different versions of Solr, Fedora, Java, etc.) the basic steps are as follows: 
- Clone the repo 
 - `git clone https://github.com/umlso-labs/islandora_vagrant_base_box`
 - `cd islandora_vagrant_base_box`
- Customize the provisioning scripts as necessary (Make note of the VM name)
- Provision the VM
 - `vagrant up`
- Export the VM to a box file 
 - `vagrant package --base <VM NAME>`
- [Upload the box file to Atlas using the web interface or otherwise](https://atlas.hashicorp.com/help/vagrant/boxes/create)

## Authors

* [Nick Ruest](https://github.com/ruebot)
* [Jared Whiklo](https://github.com/whikloj)
* [Logan Cox](https://github.com/lo5an)
* [Kevin Clarke](https://github.com/ksclarke)
* [Mark Jordan](https://github.com/mjordan)
* [Mark Cooper](https://github.com/mark-cooper)

## Acknowledgements

This project was inspired by Ryerson University Library's [Islandora Chef](https://github.com/ryersonlibrary/islandora_chef), which was inspired by University of Toronto Libraries' [LibraryChef](https://github.com/utlib/chef-islandora). So, many thanks to [Graham Stewart](https://github.com/whitepine23), and [MJ Suhonos](http://github.com/mjsuhonos/).
