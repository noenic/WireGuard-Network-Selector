#Get the name of the network
$network = (netsh wlan show interfaces | select-string " SSID") -replace " " -replace "SSID" -replace "^.."



#this is the how to get the path to this file (the script)
$filePath = $MyInvocation.MyCommand.Path;
$folderPath = Split-Path $filePath;
#Get the config file form the same folder as the script 
$json = Get-Content ($folderPath + "\config.json")| Out-String | ConvertFrom-Json;

    

#We check the status of the tunnel, if it's connected we get its name if not we get null
$wireguard = Get-NetAdapter | Where-Object {$_.InterfaceDescription -match "WireGuard Tunnel"} | Select-Object -ExpandProperty Name;


#We check if the network is in the list of networks where we don't want to activate the VPN
if ($json.networks.Contains($network)){

    #if the tunnel is active
    if ($wireguard) {
        #We disable it
        Write-Output "Wireguard tunnel is active, we disable it because the network is in the list of networks";
        wireguard /uninstalltunnelservice $wireguard
        exit 0;
    }
    else{
        #We do nothing because it's already disabled
        exit 0; 
    }
    
}
#If the network is not in the list of networks we activate the VPN
else{
    #if the tunnel is active
    if ($wireguard) {
        Write-Output "Wireguard is already active, we do nothing";
        exit 0;
    }
    else{
        Write-Output "Wireguard is disabled, we activate it because the network is not in the list of networks";
        wireguard /installtunnelservice $json.Tunnel.Directory
        exit 0;
    }
}





