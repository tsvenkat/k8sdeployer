#!/bin/sh

alias python="docker run -it --rm python:2.7.12 python"
echo "Set the following token in your inventory.yml file under k8s_info.token"
python -c 'import random; print "%0x.%0x" % (random.SystemRandom().getrandbits(3*8), random.SystemRandom().getrandbits(8*8))'
