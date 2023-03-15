##################################################################
test -n "${broadcast}" || exit 101
test -n "${forwarder_1}" || exit 102
test -n "${forwarder_2}" || exit 103
test -n "${gateway}" || exit 104
test -n "${netmask}" || exit 105
test -n "${range_min}" || exit 106
test -n "${range_max}" || exit 107
test -n "${search}" || exit 108
test -n "${subnet}" || exit 109
sudo dnf install bind dhcp-server --assumeyes
sudo tee /etc/named.conf 0<<EOF
options {
        listen-on port 53 { any; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { any; };
        forwarders { ${forwarder_1}; ${forwarder_1}; };
        forward only;
        recursion yes;
        dnssec-enable yes;
        dnssec-validation yes;
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
        include "/etc/crypto-policies/back-ends/bind.config";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
EOF
sudo tee /etc/resolv.conf 0<<EOF
search ${search}
nameserver 127.0.0.1
EOF
sudo tee /etc/dhcp/dhcpd.conf 0<<EOF
authoritative;
subnet ${subnet} netmask ${netmask} {
  range ${range_min} ${range_max};
  option domain-name-servers ${forwarder_1}, ${forwarder_2};
  option domain-name "${search}";
  option routers ${gateway};
  option broadcast-address ${broadcast};
  default-lease-time -1;
  max-lease-time -1;
}
EOF
sudo firewall-cmd --add-service=dns --zone=public --permanent
sudo firewall-cmd --reload
sudo service firewalld restart
sudo firewall-cmd --list-all
sudo systemctl enable named
sudo systemctl restart named
sudo systemctl enable dhcpd
sudo systemctl restart dhcpd
#sudo init 6
##################################################################
