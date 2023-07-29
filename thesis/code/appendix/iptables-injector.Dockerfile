FROM --platform=linux/amd64 ubuntu:22.04

RUN apt update -y
RUN apt install -y iptables jq wget
# Install crictl
ENV CRICTL_VERSION="v1.26.0"
RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
RUN tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
RUN rm -f crictl-$CRICTL_VERSION-linux-amd64.tar.gz

COPY iptables.rules iptables.rules
RUN cat << EOF\
#!/bin/bash
APP_UID=1000\
APP_PORT=8888\
SIDECAR_UID=2000\
SIDECAR_PORT=8125\
set -x\
SIDECAR_PID=$(crictl -r unix:///var/run/containerd/containerd.sock ps --name statsd -q | xargs crictl -r unix:///var/run/containerd/containerd.sock inspect | jq '.info.pid')\
nsenter -t $SIDECAR_PID -n iptables-restore < iptables.rules\
set +x\
while true; do sleep 1; done\
EOF >> iptables-file.sh

RUN cat << EOF\
#!/bin/bash\
set -x\
MAIN_PID=$(crictl -r unix:///var/run/containerd/containerd.sock ps --name node-app -q | xargs crictl -r unix:///var/run/containerd/containerd.sock inspect | jq '.info.pid')\
nsenter -t $MAIN_PID -n sysctl -w net.ipv4.conf.all.route_localnet=1\
nsenter -t $MAIN_PID -n iptables -t nat -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\
nsenter -t $MAIN_PID -n iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p udp --dport 8125 -j DNAT --to-destination 192.168.1.202:8125\
nsenter -t $MAIN_PID -n iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE\
set +x\
while true; do sleep 1; done\
EOF >> localhost-redirect.sh
