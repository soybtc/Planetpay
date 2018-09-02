#/bin/bash
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

COINGITHUB=https://github.com/PlanetPay/PlanetPay.git
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
    sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libboost-all-dev autoconf automake -qq -y > /dev/null 2>&1
    sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libgmp-dev -qq -y > /dev/null 2>&1
    sudo apt-get install openssl -qq -y > /dev/null 2>&1
    sudo apt-get install software-properties-common -qq -y > /dev/null 2>&1
    sudo add-apt-repository ppa:bitcoin/bitcoin -y > /dev/null 2>&1
    sudo apt-get update -qq -y > /dev/null 2>&1
    sudo apt-get install libdb4.8-dev libdb4.8++-dev -qq -y > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

installWallet() {
    echo
    echo -e "[6/${MAX}] Installing wallet. Please wait..."
    sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=1000 2>&1
	sudo mkswap /var/swap.img 2>&1
	sudo swapon /var/swap.img 2>&1
	sudo chmod 0600 /var/swap.img 2>&1
	sudo chown root:root /var/swap.img 2>&1
	cd ~ 2>&1
	git clone https://github.com/PlanetPay/PlanetPay.git 2>&1
	cd ~/PlanetPay/src 2>&1
	make -f makefile.unix 2>&1
    chmod 755 Planetpayd 2>&1
    strip $COINDAEMON 2>&1
    sudo mv $COINDAEMON /usr/bin 2>&1
    cd 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

configureWallet() {
    echo
    echo -e "[7/${MAX}] Configuring wallet. Please wait..."
    mkdir .Planetpay
    rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    rpcpass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}" > ~/$COINCORE/$COINCONFIG
    $COINDAEMON -daemon > /dev/null 2>&1
    sleep 10

    mnip=$(curl --silent ipinfo.io/ip)
    mnkey=$($COINDAEMON masternode genkey)

    $COINDAEMON stop > /dev/null 2>&1
    sleep 10

    echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcport=${COINRPCPORT}\nrpcallowip=127.0.0.1\nrpcthreads=8\nlisten=1\nserver=1\ndaemon=1\nstaking=0\ndiscover=1\nexternalip=${mnip}:${COINPORT}\nmasternode=1\nmasternodeprivkey=${mnkey}" > ~/$COINCORE/$COINCONFIG
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

startWallet() {
    echo
    echo -e "[8/${MAX}] Starting wallet daemon..."
    cd ~/$COINCORE
    sudo rm governance.dat > /dev/null 2>&1
    sudo rm netfulfilled.dat > /dev/null 2>&1
    sudo rm peers.dat > /dev/null 2>&1
    sudo rm -r blocks > /dev/null 2>&1
    sudo rm mncache.dat > /dev/null 2>&1
    sudo rm -r chainstate > /dev/null 2>&1
    sudo rm fee_estimates.dat > /dev/null 2>&1
    sudo rm mnpayments.dat > /dev/null 2>&1
    sudo rm banlist.dat > /dev/null 2>&1
    cd
    $COINDAEMON -daemon > /dev/null 2>&1
    sleep 5
    echo -e "${GREEN}* Done${NONE}";
}

syncWallet() {
    echo
    echo "[9/${MAX}] Waiting for wallet to sync. It will take a while, you can go grab a coffee :)";
    sleep 2
    echo -e "${GREEN}* Blockchain Synced${NONE}";
    sleep 2
    echo -e "${GREEN}* Masternode List Synced${NONE}";
    sleep 2
    echo -e "${GREEN}* Winners List Synced${NONE}";
    sleep 2
    echo -e "${GREEN}* Done reindexing wallet${NONE}";
}

clear
cd

echo
echo -e "--------------------------------------------------------------------"
echo -e "|                                                                  |"
echo -e "|         ${BOLD}----- Planetpay Coin Masternode script -----${NONE}             |"
echo -e "|                                                                  |"
echo -e "--------------------------------------------------------------------"

echo -e "${BOLD}"
read -p "This script will setup your PlanetPay Masternode. Do you wish to continue? (y/n)? " response
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
