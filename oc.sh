#!/bin/bash
sudo ./setPPT.sh 1 V56V1PPT
#sudo ./setPPT.sh 2 V56V1PPT
#sudo ./setPPT.sh 3 V56V1PPT
#sudo ./setPPT.sh 4 V56V3PPT
#Hynix
sudo ./amdmemtweak --cl 20 --ras 23 --rcdrd 15 --rcdwr 11 --rc 36 --rp 13 --rrds 3 --rrdl 5 --rtp 6 --faw 12 --cwl 7 --wtrs 4 --wtrl 9 --wr 13 --rfc 248 --REF 65535
#Samsung
#sudo ./amdmemtweak --i 2 --RAS 26 --RCDRD 12 --RCDWR 6 --RC 38 --RP 12 --REF 15600 --RRDL 4

