# Import CA Certificates
if [ -d "$CA_CERTS_DIR" ] && [ "$(ls -A $CA_CERTS_DIR)" ]; then
    echo "Importing CA certificates..."
    for cert in $CA_CERTS_DIR/*; do
        sudo cp "$cert" /usr/local/share/ca-certificates/ 2>/dev/null || sudo cp "$cert" /etc/pki/ca-trust/source/anchors/ 2>/dev/null
    done
    if [ "$DISTRO" == "ubuntu" ]; then
        sudo update-ca-certificates
    elif [ "$DISTRO" == "fedora" ]; then
        sudo update-ca-trust
    fi
else
    echo "No CA certificates directory found, or it's empty. Skipping CA imports."
fi
