#!/bin/bash -x
# ./install/fix-config.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
file=install-config.yaml						;
# MINIMUM master_type: t3a.xlarge
# MINIMUM worker_type: t3a.large
# ClusterNetworkCIDR=10.128.0.0/16
# MachineNetworkCIDR=10.0.0.0/24
# ServiceNetworkCIDR=172.30.0.0/16
# hostPrefix=20
#########################################################################
sed --in-place 								\
	/' 'platform/d 							\
	${file}								;
sed --in-place 								\
	/'cidr: 10.128.0.0.14'/s/14/$( echo ${ClusterNetworkCIDR} | cut -d/ -f2 )/			\
	${file}								;
sed --in-place 								\
	/'cidr: 10.128.0.0'/s/10.128.0.0/$( echo ${ClusterNetworkCIDR} | cut -d/ -f1 )/			\
	${file}								;
sed --in-place 								\
	/'hostPrefix: 23'/s/23/$( echo ${hostPrefix} )/							\
	${file}								;
sed --in-place 								\
	/'cidr: 10.0.0.0.16'/s/16/$( echo ${MachineNetworkCIDR} | cut -d/ -f2 )/			\
	${file}								;
sed --in-place 								\
	/'cidr: 10.0.0.0'/s/10.0.0.0/$( echo ${MachineNetworkCIDR} | cut -d/ -f1 )/			\
	${file}								;
sed --in-place 								\
	/'- 172.30.0.0.16'/s/16/$( echo ${ServiceNetworkCIDR} | cut -d/ -f2 )/				\
	${file}								;
sed --in-place 								\
	/'- 172.30.0.0'/s/172.30.0.0/$( echo ${ServiceNetworkCIDR} | cut -d/ -f1 )/			\
	${file}								;
sed --in-place 								\
	/'name.*master/s/^.*$/  name: master\n  platform:\n    aws:\n      type: '${master_type}/ 	\
	${file}								;
sed --in-place 								\
	/'name.*worker/s/^.*$/  name: worker\n  platform:\n    aws:\n      type: '${worker_type}/ 	\
	${file}								;
#########################################################################
