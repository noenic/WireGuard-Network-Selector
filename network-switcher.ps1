#We get the last event log of ID 10000 (connection to a network)
$network= Get-WinEvent -FilterHashtable @{LogName="Microsoft-Windows-NetworkProfile/Operational";ID=10000} -MaxEvents 1 | Select-Object Message | Select-Object -ExpandProperty Message;

#We create a dictionary with the language of the system and the translation of the word "Name"
$stringNameLanguage = @{
    #I don't even know if windows uses these translations (I'm french)
    "fr-FR" = "Nom";
    "en-US" = "Name";
    "es-ES" = "Nombre";
    "de-DE" = "Name";
    "it-IT" = "Nome";
    "pt-BR" = "Nome";
    "pl-PL" = "Nazwa";
    "nl-NL" = "Naam";
    "sv-SE" = "Namn";
}

#We get the translation of the word "Name" in the language of the system
$stringNameLanguage=$stringNameLanguage.(Get-WinSystemLocale | Select-Object -ExpandProperty Name);


#We get only the line with the name of the network
$network = $network -split "`n" | Where-Object {$_.Contains($stringNameLanguage)};
#We get only the name of the network
$network = $network -replace "$stringNameLanguage : ","" -replace "^." -replace ".$";

# If the network contains "Identif" then its not completely connected, So we wait till it's connected
# We will get a new event log with ID 10001 this time with the name of the network


if ($network.length -eq 0 -or $network -like "Identif*") {
    #either the network is not completely connected
    #or something went wrong and we didn't get the name of the network 
    #Probably because of the mess from the code above
    #Worst case scenario, the VPN is connected during the identification of the network or nothing happens
    exit 0;
}
#this is the how to get the path to this file (the script)
$filePath = $MyInvocation.MyCommand.Path;
$folderPath = Split-Path $filePath;
#Get the config file form the same folder as the script 
$json = Get-Content ($folderPath + "\config.json")| Out-String | ConvertFrom-Json;


#If the network in the log is the same as the network of the tunnel, that means that the VPN got activated
#by the script or by the user, in both cases we do nothing
if ($network -eq $json.Tunnel.name){
    Write-Host ($network + " IS THE SAME AS " + $json.Tunnel.name);
    exit 1;
}

#Si  $réseau commence par "Wi-Fi "
if ($network -like "Wi-Fi *") {
    #Probably the log event didn't get the name of the network
    #we need to get the name of the network ourselves
    $network = netsh wlan show interfaces | select-string " SSID"
    $network = $network -replace " " -replace "SSID" -replace "^..";
}
    

#We check the status of the tunnel, if it's connected we get its name if not we get null
$wireguard = Get-NetAdapter | Where-Object {$_.InterfaceDescription -match "WireGuard Tunnel"} | Select-Object -ExpandProperty Name;

#We check if the network is in the list of networks where we don't want to activate the VPN
if ($json.networks.Contains($network)){

    #if the tunnel is active
    if ($wireguard) {
        #We disable it
        Write-Output "Wireguard tunnel is active, we disable it because the network is in the list of networks";
        wireguard /uninstalltunnelservice $wireguard
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
    }
}





