FROM python:2.7.12
MAINTAINER tsv@hpe.com

# update apt 
RUN apt-get update && \
    apt-get install -y ssh sudo vim && \
    rm -rf /var/lib/apt/lists/*
RUN pip install ansible

# get docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.2/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine
# and docker
RUN curl https://get.docker.com/ | /bin/bash -

# Get kubectl
RUN curl -O https://storage.googleapis.com/kubernetes-release/release/v1.4.3/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/kubectl

# get helm
RUN curl -L https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | /bin/bash -
#RUN chmod 700 /get_helm.sh
#RUN /get_helm.sh
#RUN rm /get_helm.sh

# convenience script to use docker-machines as ansible inventory
# machine.py from here: https://github.com/nathanleclaire/dockerfiles/tree/master/ansible 
COPY ./machine.py /machine.py
COPY ./conf/ansible.cfg /etc/ansible/ansible.cfg
COPY ./scripts /scripts

# script that does calls required playbooks
ENTRYPOINT ["/scripts/deploy.sh"]
