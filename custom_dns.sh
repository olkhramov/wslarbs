#!/bin/bash

# Path to the file containing custom DNS server addresses
CUSTOM_DNS_FILE="custom_dns_servers.txt"

# Path to the resolv.conf file
RESOLV_CONF="/etc/resolv.conf"

# Check if the custom DNS servers file exists
if [ ! -f "$CUSTOM_DNS_FILE" ]; then
    echo "The custom DNS servers file does not exist: $CUSTOM_DNS_FILE"
    exit 1
fi

# Prevent WSL from generating /etc/resolv.conf automatically
echo "[network]" | sudo tee /etc/wsl.conf
echo "generateResolvConf = false" | sudo tee -a /etc/wsl.conf

# Backup the existing resolv.conf
sudo cp $RESOLV_CONF "${RESOLV_CONF}.backup"

# Clear the contents of resolv.conf (optional)
echo -n | sudo tee $RESOLV_CONF

# Read each DNS server from the file and add it to resolv.conf
while IFS= read -r dns_server; do
    if [[ -n "$dns_server" ]]; then  # Check if line is not empty
        echo "Adding DNS server: $dns_server to $RESOLV_CONF"
        echo "nameserver $dns_server" | sudo tee -a $RESOLV_CONF > /dev/null
    fi
done < "$CUSTOM_DNS_FILE"

echo "$RESOLV_CONF has been updated with custom DNS servers."


# Function to prompt user for Y/N answer
ask_restart_wsl() {
    while true; do
        read -p "Do you want to restart WSL now? (y/n): " yn
        case $yn in
            [Yy]* )
                echo "Restarting WSL..."
                wsl.exe --shutdown
                echo "WSL has been restarted. Please reopen your WSL terminal."
                exit;;
            [Nn]* )
                echo "WSL will not be restarted. Remember to restart it manually if needed."
                exit;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Call the function
ask_restart_wsl