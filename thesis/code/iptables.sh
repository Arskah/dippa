#!/bin/bash
APP_UID=1000
APP_PORT=8888
SIDECAR_UID=2000
SIDECAR_PORT=8125

# Ingress rules
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport $APP_PORT -j ACCEPT # Scenarios 1, 2
iptables -A INPUT -i lo -p tcp --dport $SIDECAR_PORT -j ACCEPT # Scenario 3
iptables -A INPUT -j DROP

# Egress rules
iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

## Main app rules
iptables -A OUTPUT -d 127.0.0.1 -m owner --uid-owner $APP_UID -p tcp --dport $APP_PORT -j ACCEPT # Scenario 2
iptables -A OUTPUT -d 127.0.0.1 -m owner --uid-owner $APP_UID -p tcp --dport $SIDECAR_PORT -j ACCEPT # Scenario 2

## Sidecar rules
iptables -A OUTPUT -d 127.0.0.1 -m owner --uid-owner $SIDECAR_UID -p tcp --dport $SIDECAR_PORT -j ACCEPT

iptables -A OUTPUT -j REJECT
