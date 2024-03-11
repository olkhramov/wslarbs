Start-Sleep -Seconds 3
Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "PANGP"} | Set-NetIPInterface -InterfaceMetric 6000
Get-NetIPInterface -InterfaceAlias "vEthernet (WSL)" | Set-NetIPInterface -InterfaceMetric 1
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show('The network configuration has been changed to enable connectivity in WSL2')
