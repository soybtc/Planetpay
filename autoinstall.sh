#/bin/bash
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
MAX=9

COINGITHUB=https://github.com/PlanetPay/PlanetPay
COINPORT=13127
COINRPCPORT=13126
COINDAEMON=Planetpayd
COINCORE=.Planetpay
COINCONFIG=Planetpay.conf

checkForUbuntuVersion() {
   echo "[1/${MAX}] Checking Ubuntu version..."
    if [[ `cat /etc/issue.net`  == *16.04* ]]; then
        echo -e "${GREEN}* You are running `cat /etc/issue.net` . Setup will continue.${NONE}";
    else
        echo -e "${RED}* You are not running Ubuntu 16.04.X. You are running `cat /etc/issue.net` ${NONE}";
        echo && echo "Installation cancelled" && echo;
        exit;
    fi
}

updateAndUpgrade() {
    echo
    echo "[2/${MAX}] Runing update and upgrade. Please wait..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y > /dev/null 2>&1
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq > /dev/null 2>&1
    echo -e "${GREEN}* Done${NONE}";
}

installFail2Ban() {
    echo
    echo -e "[3/${MAX}] Installing fail2ban. Please wait..."
    sudo apt-get -y install fail2ban > /dev/null 2>&1
    sudo systemctl enable fail2ban > /dev/null 2>&1
    sudo systemctl start fail2ban > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

installFirewall() {
    echo
    echo -e "[4/${MAX}] Installing UFW. Please wait..."
    sudo apt-get -y install ufw > /dev/null 2>&1
    sudo ufw default deny incoming > /dev/null 2>&1
    sudo ufw default allow outgoing > /dev/null 2>&1
    sudo ufw allow ssh > /dev/null 2>&1
    sudo ufw limit ssh/tcp > /dev/null 2>&1
    sudo ufw allow $COINPORT/tcp > /dev/null 2>&1
    sudo ufw allow $COINRPCPORT/tcp > /dev/null 2>&1
    sudo ufw logging on > /dev/null 2>&1
    echo "y" | sudo ufw enable > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

installDependencies() {
    echo
    echo -e "[5/${MAX}] Installing dependencies. Please wait..."
	sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libboost-all-dev autoconf automake 2>&1
	sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -y 2>&1
	sudo apt-get install git 2>&1
	git clone https://github.com/bitcoin-core/secp256k1 2>&1
	cd ~/secp256k1 2>&1
	./autogen.sh 2>&1
	./configure 2>&1
	make 2>&1
	./tests 2>&1
	sudo make install 2>&1
	sudo apt-get install libgmp-dev 2>&1
	sudo apt-get install openssl 2>&1
	apt-get install software-properties-common && add-apt-repository ppa:bitcoin/bitcoin 2>&1
	apt-get update 2>&1
	apt-get install libdb4.8-dev libdb4.8++-dev 2>&1
	sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=1000 2>&1
	sudo mkswap /var/swap.img 2>&1
	sudo swapon /var/swap.img 2>&1
	sudo chmod 0600 /var/swap.img 2>&1
	sudo chown root:root /var/swap.img 2>&1
	cd ~ 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

installWallet() {
    echo
    echo -e "[6/${MAX}] Installing wallet. Please wait..."
    git clone https://github.com/PlanetPay/PlanetPay
    cd ~/PlanetPay/src
    make -f makefile.unix
    chmod 755 Planetpayd
    strip $COINDAEMON
    sudo mv $COINDAEMON /usr/bin
    cd
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

clear
cd

echo
echo -e "--------------------------------------------------------------------"
echo -e "|                                                                  |"
echo -e "|         ${BOLD}----- PlanetPay Masternode script -----${NONE}          |"
echo -e "|                                                                  |"
echo -e "|                                                                  |"
echo -e "|           ${CYAN}€€€€€€€\  €€\                                €€\     €€€€€€€\${NONE}                                               |"
echo -e "|           ${CYAN}€€  __€€\ €€ |                               €€ |    €€  __€€\${NONE}                                              |"
echo -e "|           ${CYAN}€€ |  €€ |€€ | €€€€€€\  €€€€€€€\   €€€€€€\ €€€€€€\   €€ |  €€ |€€€€€€\  €€\   €€\${NONE}                           |"
echo -e "|           ${CYAN}€€€€€€€  |€€ | \____€€\ €€  __€€\ €€  __€€\\_€€  _|  €€€€€€€  |\____€€\ €€ |  €€ |${NONE}                          |" 
echo -e "|           ${CYAN}€€  ____/ €€ | €€€€€€€ |€€ |  €€ |€€€€€€€€ | €€ |    €€  ____/ €€€€€€€ |€€ |  €€ |${NONE}                          |"                   
echo -e "|           ${CYAN}€€ |      €€ |€€  __€€ |€€ |  €€ |€€   ____| €€ |€€\ €€ |     €€  __€€ |€€ |  €€ |${NONE}                          |"
echo -e "|           ${CYAN}€€ |      €€ |\€€€€€€€ |€€ |  €€ |\€€€€€€€\  \€€€€  |€€ |     \€€€€€€€ |\€€€€€€€ |${NONE}                          |"
echo -e "|           ${CYAN}\__|      \__| \_______|\__|  \__| \_______|  \____/ \__|      \_______| \____€€ |${NONE}                          |"
echo -e "|           ${CYAN}                                                                        €€\   €€ |${NONE}                          |"
echo -e "|           ${CYAN}                                                                        \€€€€€€  |${NONE}                          |"
echo -e "|           ${CYAN}                                                                         \______/ ${NONE}                          |"
echo -e "|                                                                  |"
echo -e "--------------------------------------------------------------------"

echo -e "${BOLD}"
read -p "This script will setup your Planetpay Masternode. Do you wish to continue? (y/n)? " response
echo -e "${NONE}"

if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    checkForUbuntuVersion
    updateAndUpgrade
    installFail2Ban
    installFirewall
    installDependencies
    installWallet
    configureWallet
    startWallet
    syncWallet

    echo
    echo -e "${BOLD}The VPS side of your masternode has been installed. Use the following line in your cold wallet masternode.conf and replace the tx and index${NONE}".
    echo
    echo -e "${CYAN}masternode1 ${mnip}:${COINPORT} ${mnkey} tx index${NONE}"
    echo
    echo -e "${BOLD}Continue with the cold wallet part of the guide${NONE}"
    echo
else
    echo && echo "Installation cancelled" && echo
fi
