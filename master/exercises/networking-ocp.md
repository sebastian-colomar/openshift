```
sh-4.4# iptables -S -t nat | grep hasher
-A KUBE-SERVICES ! -s 10.128.0.0/14 -d 172.30.86.118/32 -p tcp -m comment --comment "dockercoins/hasher cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 172.30.86.118/32 -p tcp -m comment --comment "dockercoins/hasher cluster IP" -m tcp --dport 8080 -j KUBE-SVC-TAXIZUTWLLJVS3DC
-A KUBE-SVC-TAXIZUTWLLJVS3DC -m comment --comment "dockercoins/hasher" -j KUBE-SEP-HLPP5TT464ZJVMKS
-A KUBE-SEP-HLPP5TT464ZJVMKS -s 10.128.2.157/32 -m comment --comment "dockercoins/hasher" -j KUBE-MARK-MASQ
-A KUBE-SEP-HLPP5TT464ZJVMKS -p tcp -m comment --comment "dockercoins/hasher" -m tcp -j DNAT --to-destination 10.128.2.157:8080
sh-4.4# iptables -S -t nat | grep hasher
-A KUBE-SERVICES ! -s 10.128.0.0/14 -d 172.30.86.118/32 -p tcp -m comment --comment "dockercoins/hasher cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 172.30.86.118/32 -p tcp -m comment --comment "dockercoins/hasher cluster IP" -m tcp --dport 8080 -j KUBE-SVC-TAXIZUTWLLJVS3DC
-A KUBE-SVC-TAXIZUTWLLJVS3DC -m comment --comment "dockercoins/hasher" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-HLPP5TT464ZJVMKS
-A KUBE-SVC-TAXIZUTWLLJVS3DC -m comment --comment "dockercoins/hasher" -j KUBE-SEP-VRUP5YGT7HG7NASS
-A KUBE-SEP-HLPP5TT464ZJVMKS -s 10.128.2.157/32 -m comment --comment "dockercoins/hasher" -j KUBE-MARK-MASQ
-A KUBE-SEP-HLPP5TT464ZJVMKS -p tcp -m comment --comment "dockercoins/hasher" -m tcp -j DNAT --to-destination 10.128.2.157:8080
-A KUBE-SEP-VRUP5YGT7HG7NASS -s 10.129.3.114/32 -m comment --comment "dockercoins/hasher" -j KUBE-MARK-MASQ
-A KUBE-SEP-VRUP5YGT7HG7NASS -p tcp -m comment --comment "dockercoins/hasher" -m tcp -j DNAT --to-destination 10.129.3.114:8080
sh-4.4# iptables -S -t nat | grep hasher
-A KUBE-SERVICES ! -s 10.128.0.0/14 -d 172.30.86.118/32 -p tcp -m comment --comment "dockercoins/hasher cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 172.30.86.118/32 -p tcp -m comment --comment "dockercoins/hasher cluster IP" -m tcp --dport 8080 -j KUBE-SVC-TAXIZUTWLLJVS3DC
-A KUBE-SVC-TAXIZUTWLLJVS3DC -m comment --comment "dockercoins/hasher" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-HLPP5TT464ZJVMKS
-A KUBE-SVC-TAXIZUTWLLJVS3DC -m comment --comment "dockercoins/hasher" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-VRUP5YGT7HG7NASS
-A KUBE-SVC-TAXIZUTWLLJVS3DC -m comment --comment "dockercoins/hasher" -j KUBE-SEP-43IDXD3H6ZTFRS26
-A KUBE-SEP-HLPP5TT464ZJVMKS -s 10.128.2.157/32 -m comment --comment "dockercoins/hasher" -j KUBE-MARK-MASQ
-A KUBE-SEP-HLPP5TT464ZJVMKS -p tcp -m comment --comment "dockercoins/hasher" -m tcp -j DNAT --to-destination 10.128.2.157:8080
-A KUBE-SEP-VRUP5YGT7HG7NASS -s 10.129.3.114/32 -m comment --comment "dockercoins/hasher" -j KUBE-MARK-MASQ
-A KUBE-SEP-VRUP5YGT7HG7NASS -p tcp -m comment --comment "dockercoins/hasher" -m tcp -j DNAT --to-destination 10.129.3.114:8080
-A KUBE-SEP-43IDXD3H6ZTFRS26 -s 10.131.1.205/32 -m comment --comment "dockercoins/hasher" -j KUBE-MARK-MASQ
-A KUBE-SEP-43IDXD3H6ZTFRS26 -p tcp -m comment --comment "dockercoins/hasher" -m tcp -j DNAT --to-destination 10.131.1.205:8080
```
