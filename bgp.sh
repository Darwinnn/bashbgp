#!/bin/bash

opensent=0
updatesent=0
marker="\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"
myas="\x00\x64" # 100
routerid="\x01\x01\x01\x01" # 1.1.1.1
holdtime="\x00\x1e" # 30

######## attributes
origin="\x40\x01\x01\x00" # trans well known, type 1 (origin), len 1, value 0 (igp)
#
as_path="\x40\x02\x04" # trans wellknown, type 2 (as_path), len 4
as_path_as_seq="\x02\x01$myas" # seg_type: 2 (as_seq), seg_len 1
as_path_att="$as_path$as_path_as_seq"
#
next_hop="\x40\x03\x04\x01\x01\x01\x01" # trans wellknown, len 4, 1.1.1.1
#
nlri="\x20\x01\x01\x01\x01" # len 32 (0x20), prefix 1.1.1.1
########


while true
do
 if [ $opensent == "0" ]
 then
    printf "$marker\x00\x1d\x01\x04$myas$holdtime$routerid\x00" # simple open without optional capabilities
    opensent=1
 fi
 sleep 10
 printf "$marker\x00\x13\x04" # length 19, type 4 (keepalive)
 sleep 1 
 if [ $updatesent == "0" ]
 then
    printf "$marker\x00\x2e\x02\x00\x00\x00\x12$origin$as_path_att$next_hop$nlri" # len 46, type 2 (update), withdrawn len 0, path att len 18
    updatesent=1
 fi
 sleep 3
done | nc -l 179
