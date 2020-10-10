# Get-ADComputerBitlockerStatus
## Short description
I was faced with a problem of missing Bitlocker key for a domain joined Windows machine. Upon doing a quick search I found out it wasn't the only case and I might be facing a domain wide problem. Regardless of the reason why it was missing I wanted to get a domain wide report of our computers and their Bitlocker keys.

## What does it do?
The script does a search for all ADComputer objects and all Bitlocker keys (objectClass = *msFVE-RecoveryInformation*).
