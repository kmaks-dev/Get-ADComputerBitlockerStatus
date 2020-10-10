[CmdletBinding()]
Param ()
begin {}
    
process {
    $BitlockerListConfig = @{
        Filter      = {objectclass -like "msFVE-RecoveryInformation"}
        Properties  = "*"
    }
    $BitLockerList = Get-ADObject @BitlockerListConfig |
        Select-Object -Property whenCreated, `
            @{n="Parent";e={ $_.DistinguishedName -Replace '^.*?,'}} |
        Group-Object -Property Parent |
        Select-Object -Property Name, `
            @{n="WhenCreated";e={ $_.Group.WhenCreated | sort -Descending | select -first 1 }}
    
    $AdComputerListConfig = @{
        Filter      = {name -like "*"}
        Properties  = "*"
    }
    $AdComputerList = Get-ADComputer @AdComputerListConfig |
        Select-Object -Property *, `
            @{n="HasBitLockerData";e={($False,$True)[$BitLockerList.Name.Contains($_.DistinguishedName)]}}, `
            @{n="OU";e={$_.DistinguishedName -replace '^.*?,'}}, `
            @{n="LatestBitLockerDate";e={($BitLockerList | Where-Object Name -eq $_.DistinguishedName | Select-Object -ExpandProperty whenCreated).ToString('dd.MM.yyyy HH:mm:ss') }}

    $Return = $AdComputerList | Select-Object -Property `
        Name, `
        @{n="LastLogonDate";e={$_.LastLogOnDate.ToString('dd.MM.yyyy HH:mm:ss')}}, `
        OU, `
        OperatingSystem, `
        HasBitLockerData, `
        LatestBitLockerDate
}

end {
    $Return | Export-Csv -LiteralPath (".\ADBitlockerAudit_{0}.csv" -f (Get-Date).ToString('yyyyMMdd_HHmm')) -Encoding UTF8
    Return $Return
}
