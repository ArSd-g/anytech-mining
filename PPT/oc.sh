#!/bin/bash
sudo ./setPPT.sh 1 V56V3PPT
sudo ./setPPT.sh 2 V56V3PPT
sudo ./setPPT.sh 3 V56V3PPT
sudo ./setPPT.sh 4 V56V3PPT
sudo ./amdmemtweak --i 0,1,3 --RAS 30 --RCDRD 14 --RCDWR 6 --RC 38 --RP 12 --REF 15600 --RRDL 4
sudo ./amdmemtweak --i 2 --RAS 26 --RCDRD 12 --RCDWR 6 --RC 38 --RP 12 --REF 15600 --RRDL 4

