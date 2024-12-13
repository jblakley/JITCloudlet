#!/bin/bash
echo wireshark-common/install-setuid wireshark-common/install-setuid select true|sudo debconf-set-selections
dpkg-reconfigure -f noninteractive wireshark-common
groupadd pcap
usermod -a -G pcap $1
usermod -a -G wireshark $1
ls /usr/sbin/tcpdump && export TCPDUMP=/usr/sbin/tcpdump || export TCPDUMP=/usr/bin/tcpdump
chgrp pcap ${TCPDUMP}
chmod 750  ${TCPDUMP}
# setcap cap_net_aw,cap_net_admin=eip /usr/sbin/tcpdump
setcap "CAP_NET_RAW+eip"  ${TCPDUMP}

