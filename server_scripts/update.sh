#!/bin/sh

grep localhost:5000 cloud-config.yml | xargs -n 1 docker pull

sudo coreos-cloudinit -from-file=./cloud-config.yml
sudo cp cloud-config.yml /var/lib/coreos-install/user_data
