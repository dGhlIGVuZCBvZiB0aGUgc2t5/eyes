#!/bin/bash
unset history

# globals
if [ "$1" ]; then
    keyword="$1"
else
    keyword="flag{"
fi
report="$(hostname).report"
net="$(hostname).net"
meta="$(hostname).meta"
runtime="$(hostname).run"
hunt="$(hostname).hunt"

# check dependencies
shredpath=$(which shred)
ippath=$(which ip)
sspath=$(which ss)

# setup file structure
mkdir .tmp
cd .tmp

touch $report
touch $net
touch $meta
touch $runtime
touch $hunt

test () {
    echo "this is a test" >> $report
}

sysinfo () {
    # sysinfo
    echo -e "\n" >> $meta
    echo -e "[[ META INFO ]]\n" >> $meta
    echo -e "[ user ]\n" >> $meta
    echo $(whoami)@$(hostname) >> $meta
    echo -e "" >> $meta
    id >> $meta
    echo -e "\n[ end section ]\n" >> $meta
    echo -e "\n" >> $meta

    echo -e "[ env ]\n" >> $meta
    env | grep -v LS_COLORS >> $meta
    echo -e "\n[ end section ]\n" >> $meta
    echo -e "\n" >> $meta

    echo -e "[ kernel + os ]\n" >> $meta
    uname -a >> $meta
    echo -e "" >> $meta
    lscpu >> $meta
    echo -e "\n[ end section ]\n" >> $meta
    echo -e "\n" >> $meta

    echo -e "[ logged in ]\n" >> $meta
    who >> $meta
    echo -e "" >> $meta
    w >> $meta
    echo -e "\n[ end section ]\n" >> $meta
    echo -e "\n" >> $meta

    echo -e "[ sudoers ]\n" >> $meta
    cat /etc/group | grep "sudo:" | cut -d ":" -f 4 >> $meta
    echo -e "\n[ end section ]\n" >> $meta
    echo -e "\n" >> $meta

    echo -e "[ passwd ]\n" >> $meta
    cat /etc/passwd >> $meta
    echo -e "\n[ end section ]\n" >> $meta
    echo -e "\n" >> $meta

    echo -e "[ groups ]\n" >> $meta
    cat /etc/group >> $meta
    echo -e "\n[ end section ]\n" >> $meta
    echo -e "\n" >> $meta

    echo -e "[ shadow ]\n" >> $meta
    cat /etc/shadow 2>/dev/null >> $meta
    echo -e "\n[ end section ]\n" >> $meta
    echo -e "\n" >> $meta

    echo -e "[ /home/ ]\n" >> $meta
    ls -l /home >> $meta 
    echo -e "\n[ end section ]\n" >> $meta 
    echo -e "\n" >> $meta 
}

network () {
    # networking
    echo -e "\n" > $net
    echo -e "[[ NETWORKING ]]\n" 2>/dev/null >> $net
    echo -e "[ interfaces ]\n" 2>/dev/null >> $net
    if [ "$ippath" ]; then
        ip a 2>/dev/null >> $net
    else
        ifconfig 2>/dev/null >> $net
    fi
    echo -e "\n[ end section ]\n" 2>/dev/null >> $net 
    echo -e "\n" 2>/dev/null >> $net

    echo -e "[ netstat ]\n" 2>/dev/null >> $net
    if [ "$sspath" ]; then
        ss -pantu 2>/dev/null >> $net
    else
        netstat -pantu 2>/dev/null >> $net
    fi
    echo -e "\n[ end section ]\n" 2>/dev/null >> $net 
    echo -e "\n" 2>/dev/null >> $net

    echo -e "[ arp ]\n" 2>/dev/null >> $net
    arp -a 2>/dev/null >> $net
    echo -e "\n[ end section ]\n" 2>/dev/null >> $net 
    echo -e "\n" 2>/dev/null >> $net

    echo -e "[ routes ]\n" 2>/dev/null >> $net
    if [ "$ippath" ]; then
        ip route 2>/dev/null >> $net
    else
        route 2>/dev/null >> $net
    fi
    echo -e "\n[ end section ]\n" 2>/dev/null >> $net 
    echo -e "\n" 2>/dev/null >> $net

    echo -e "[ /etc/hosts ]\n" 2>/dev/null >> $net
    cat /etc/hosts 2>/dev/null >> $net
    echo -e "\n[ end section ]\n" 2>/dev/null >> $net 
    echo -e "\n" 2>/dev/null >> $net

    echo -e "[ resolv.conf ]\n" 2>/dev/null >> $net
    cat /etc/resolve.conf 2>/dev/null >> $net
    echo -e "\n[ end section ]\n" 2>/dev/null >> $net 
    echo -e "\n" 2>/dev/null >> $net
}

runtime () {
    # runtime
    echo -e "\n" > $runtime
    echo -e "[[ RUNTIME ]]\n" 2>/dev/null >> $runtime
    echo -e "[ processes ]\n" 2>/dev/null >> $runtime
    ps axjf 2>/dev/null >> $runtime
    echo -e "\n[ end processes]\n" 2>/dev/null >> $runtime
    echo -e "\n" 2>/dev/null >> $runtime

    echo -e "[ top 100 files modified in the last day ]\n" 2>/dev/null >> $runtime
    for file in $( \
            find / -type f -mtime -1 2>/dev/null | \
            grep -v "/run/" | \
            grep -v "/var/" | \
            grep -v "/proc/" | \
            head -n 100 \
        );
        do ls -lah $file 2>/dev/null >> $runtime; 
    done
    echo -e "\n[ end section ]\n" 2>/dev/null >> $runtime 
    echo -e "\n" 2>/dev/null >> $runtime 

    echo -e "[ hidden files ]\n" 2>/dev/null >> $runtime
    find /home -name ".*" -type f -exec ls -al {} \; 2>/dev/null >> $runtime
    find /var/www -name ".*" -type f -exec ls -al {} \; 2>/dev/null >> $runtime
    find /opt -name ".*" -type f -exec ls -al {} \; 2>/dev/null >> $runtime
    find /srv -name ".*" -type f -exec ls -al {} \; 2>/dev/null >> $runtime
    echo -e "\n[ end section ]\n" 2>/dev/null >> $runtime 
    echo -e "\n" 2>/dev/null >> $runtime

    echo -e "[ scheduled tasks ]\n" 2>/dev/null >> $runtime
    crontab -l 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    ls -la /etc/cron* 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    ls -la /etc/init.d/ 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    ls -la /etc/rc.d/ 2>/dev/null >> $runtime
    echo -e "\n[ end section ]\n" 2>/dev/null >> $runtime 
    echo -e "\n" 2>/dev/null >> $runtime

    echo -e "[ SUID + SGID ]\n" 2>/dev/null >> $runtime
    find / -perm -1000 -type d 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    find / -perm -g=s -o -perm -u=s -type f 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    for i in `locate -r "bin$"`; do find $i \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null >> $runtime; done
    find / -perm -g=s -o -perm -4000 ! -type l -maxdepth 3 -exec ls -ld {} \; 2>/dev/null >> $runtime
    echo -e "\n[ end section ]\n" 2>/dev/null >> $runtime 
    echo -e "\n" 2>/dev/null >> $runtime

    echo -e "[ useful files ]" 2>/dev/null >> $runtime
    which nc 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    which nmap 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    which wget 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    which curl 2>/dev/null >> $runtime
    echo -e "" 2>/dev/null >> $runtime
    which netcat 2>/dev/null >> $runtime
    echo -e "\n[ end section ]\n" 2>/dev/null >> $runtime 
    echo -e "\n" 2>/dev/null >> $runtime
}

interesting () {
    # interesting files
    echo -e "\n" > $hunt
    echo -e "[[ KEYSEARCH ]]\n" 2>/dev/null >> $hunt
    echo -e "[ bash_history ]\n" 2>/dev/null >> $hunt
    find / -name *bash_history 2>/dev/null >> $hunt
    echo -e "\n[ end section ]\n" 2>/dev/null >> $hunt 
    echo -e "\n" 2>/dev/null >> $hunt

    echo -e "[ priv keys ]\n" 2>/dev/null >> $hunt
    grep -rl "PRIVATE KEY-----" / 2>/dev/null >> $hunt
    echo -e "\n[ end section ]\n" 2>/dev/null >> $hunt 
    echo -e "\n" 2>/dev/null >> $hunt

    echo -e "[ flag search ]\n" 2>/dev/null >> $hunt
    grep -irl $keyword / 2>/dev/null >> $hunt
    echo -e "\n[ end section ]\n" 2>/dev/null >> $hunt 
    echo -e "\n" 2>/dev/null >> $hunt
}

gather () {
    cat $meta >> $report
    cat $net >> $report
    cat $runtime >> $report
    cat $hunt >> $report
    if [ ! $minimal ]; then
        mkdir logs
        cp -r /var/log/* ./logs/ 2>/dev/null
        mkdir homes
        cp -r /home/* homes/ 2>/dev/null
    fi
    cd ..
    tar -czvf pkg .tmp/ 2>/dev/null >/dev/null
    if [ "$shredpath" ]; then 
        echo "[#] shredding"
        find .tmp -type f -exec shred -fu {} \;
    else
        echo "[#] not shredded"
    fi
    rm -rf .tmp
}

# MAIN 
while getopts "k:mht" option; do
 case "${option}" in
    k) keyword=${OPTARG};;
    m) minimal="TRUE";;
    t) thorough="TRUE";;
    h) usage; exit;;
    *) usage; exit;;
 esac
done
echo [ $(date) ] > $report
sysinfo && echo "...sysinfo done" && \
network && echo "...network done" && \
runtime && echo "...runtime done" &&
if [ "$thorough" ]; then
    interesting && echo "...keyfiles done" && gather
else
    gather
fi

#$( test ) && gather
