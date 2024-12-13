sudo echo >  /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
sudo iptables -I INPUT -i ogstun -j ACCEPT
sudo ufw disable
sudo ufw status
sudo bash -c '(iptables -t nat -L -n -v;iptables -L -n -v)|more'
