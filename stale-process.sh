#!/bin/bash
# Alberto Pinardi 
# alberto.pinardi@musixmatch.com
# Controll and Kill a target process between a user defined interval

workdir="/tmp/.stale_process_killing"
[ -d "$workdir" ] || mkdir "$workdir"

function usage() {
  echo "Usage: $0 [-t <target process>] [-w <wait time>]"
  exit 1
}

# parsing arguments
while getopts t:w:? option
do
  case "${option}"
  in
    t) target=${OPTARG};;
    w) wait=${OPTARG};;
    ?) usage;;
  esac
done

# get ps aux outputs, 2 iteractions
for ((i=1; i<3; i++)); do
    # add file number to file
    echo $i > "${workdir}/psaux${i}"
    # add ps output to file
    ps aux | grep $target >> "${workdir}/psaux${i}"
    sleep $wait
done

# now parse the files using awk
awk '
    FNR==1 { ix = $1 }
    FNR!=1 { cpu[$2][ix] = $3 }
    END {
        for (pid in cpu) { 
            j=1;
            while (cpu[pid][j] == cpu[pid][j+1] && j <= ix) {
                if (cpu[pid][j++] == "") {
                    j=1;
                    break;
                }
            }
            if (j >= ix) {
                system("kill " pid);
            }
        }
    }' "${workdir}/psaux"*