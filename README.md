# How does it work
The powershell script retrieves the network on which the computer is connected and depending on whether the network is trusted or not enables or disables the VPN.

To do this, the script needs to know which network you trust and which wireguard tunnel to activate or deactivate. To do this, you need to add them to the config.json file following the template.

Now we need the script to be executed each time we connect to a new network, manually it's rather counter productive, so we'll associate it to a windows event with the Event Viewer and the task scheduler


# Create the task
Create a task triggered by an event 

<strong>Trigger :</strong>
- LOG  is  *"Microsoft-Windows-Network Profile/Operational"*
- SOURCE is *"NetworkProfile"*
- event ID is *10000*

<strong>Action:</strong>
- Start a programm (*powershell -ExecutionPolicy ByPass -File "[PATH_TO]\network-switcher.ps1"*)

<strong>Other Settings:</strong>
- Run the with highest privileges (Because wireguard command can only be run under admin privileges)
- Run whether the user is logged in or not (So the powershell window is not displayed)
- Uncheck the box "Start the task only if the computer is on AC Power" (otherwise the script will not run on battery).


# Requirements
Wireguard must be in the PATH *(type "wireguard" in the command terminal and see if it opens the wireguard UI)*



