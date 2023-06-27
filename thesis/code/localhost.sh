    #!/bin/bash
    sysctl -w net.ipv4.conf.all.route_localnet=1
    iptables -t nat -A OUTPUT -p ALL --dport 8125 -j DNAT --to-destination 192.168.1.202:8125
    iptables -t nat -A POSTROUTING -j MASQUERADE
