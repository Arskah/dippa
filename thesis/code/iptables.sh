#!/bin/bash
APP_UID=1000
APP_PORT=8888
SIDECAR_UID=2000
SIDECAR_PORT=8125

# Ingress rules
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport $APP_PORT -j ACCEPT
iptables -A INPUT -p udp --dport $SIDECAR_PORT -j ACCEPT
iptables -A INPUT -j DROP

# Egress rules
iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

## Main app rules
iptables -A OUTPUT -o lo -m owner --uid-owner $APP_UID -p tcp --dport $APP_PORT -j ACCEPT
iptables -A OUTPUT -o lo -m owner --uid-owner $APP_UID -p udp --dport $SIDECAR_PORT -j ACCEPT

## Sidecar rules
iptables -A OUTPUT -o lo -m owner --uid-owner $SIDECAR_UID -p udp --dport $SIDECAR_PORT -j ACCEPT

iptables -A OUTPUT -j REJECT
