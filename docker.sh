#!/bin/bash
set -e

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install tzdata -y
apt-get install automake autoconf libconfig-dev libssl-dev libtool pkg-config python3-pip git sudo -y
pip3 install robotframework
