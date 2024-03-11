# wslarbs
WSL Auto Rice Bootstrap scripts

## What is this?

This is a set of scripts that will automatically setup a WSL with all the programs needed. It works with Fedora & Ubuntu.

## How to use it?

1. Clone this repository
2. Optional: modify the list of programs in the `programs` file
3. Run the `install.sh` script
4. Use the WSL

## DNS issues

If you have DNS issues, you can try to change the DNS server in the `/etc/resolv.conf` file. 
You can find script here that would do that for you, just specify DNS servers you want in `custom_dns_servers.txt` file.
Then:

```bash
chmod +x change_dns.sh
./change_dns.sh
```

## CA certificates

Your organization may have its own CA certificates. You can add them to the WSL by putting them in the `ca-certificates` directory. The `install.sh` script will automatically copy them to the right place. Just make sure the files are in the right format (`.crt`).

## Annex: Before you start

You need to have WSL installed. If you don't have it, you can install it by following the instructions [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

TL;DR: Open PowerShell as Administrator and run:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Then install wsl itself:

```powershell
wsl --install
```

Set WSL 2 as the default version:

```powershell
wsl --set-default-version 2
```

> This is where you probably need to restart your PC

Then select a distro:

```powershell
wsl --list --online
```

And install it:

```powershell
wsl --install -d <distro>
```
