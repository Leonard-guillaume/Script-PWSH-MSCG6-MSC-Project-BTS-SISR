#NAME: folder_tree_create.ps1
#AUTHOR: LE BIHAN Baptiste
#DATE: 15/12/2025
#VERSION 1.0
#Powershell version 

Import-Module activedirectory

$scriptName =$MyInvocation.MyCommand.Name
$ScriptNameNoExt = $scriptName.Substring(0, $scriptName.Length - 4)

Write-Host -ForegroundColor Green "`n----- Exécution script $PSScriptRoot\$scriptName -----"
Write-Host -ForegroundColor Magenta "      Création de dossiers"


$folderFeature = Import-csv -path "$PSScriptRoot\$ScriptNameNoExt.csv" -Delimiter ";"
foreach ($item in $folderFeature)
{
	$folderNamePath	= $item.folderNamePath
    $remoteServerName =  $item.remoteServerName
    $remoteLetterPartitionDest =  $item.remoteLetterPartitionDest

    try
    {
        $msg = "Try creating folder : $remoteLetterPartitionDest\$folderNamePath on $remoteServerName"
        Write-Host -Foregroundcolor Yellow $msg
    }
    catch
    {
        Write-Host -ForegroundColor Red $error[0]
    }
}

$rep = Read-Host "Voulez-vous réaliser ces opérations ? y/n (n)"
if($rep -eq 'y')
{
    foreach ($item in $folderFeature)
    {
	    $folderNamePath	= $item.folderNamePath
        $remoteServerName =  $item.remoteServerName
        $remoteLetterPartitionDest =  $item.remoteLetterPartitionDest

        try
        {
            New-Item -Path \\$remoteServerName\C$\$folderNamePath –type directory -ErrorAction Stop
            $msg = "folder $remoteLetterPartitionDest\$folderNamePath created on $remoteServerName"
            Write-Host -ForegroundColor Green $msg
        }
        catch
        {
            Write-Host -ForegroundColor Red $error[0]
        }
    }
}
Write-Host -ForegroundColor Green "----- Fin script $PSScriptRoot\$scriptName -----"
