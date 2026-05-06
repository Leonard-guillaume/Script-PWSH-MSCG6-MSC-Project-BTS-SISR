#NAME: folder_right_and_share.ps1
#AUTHOR: LE BIHAN Baptiste
#DATE: 15/12/2025
#VERSION 1.0
#Powershell version 

Import-Module activedirectory

$scriptName =$MyInvocation.MyCommand.Name
$ScriptNameNoExt = $scriptName.Substring(0, $scriptName.Length - 4)

Write-Host -ForegroundColor Green "`n----- Exécution script $PSScriptRoot\$scriptName -----"
Write-Host -ForegroundColor Magenta "      Création de dossiers"


$FolderShare = Import-csv -path "$PSScriptRoot\$ScriptNameNoExt.csv" -Delimiter ";"

foreach ($Sharing in $FolderShare) {

    $ShareName      = $Sharing.ShareName
    $FolderPath     = $Sharing.FolderPath
    $Group          = $Sharing.Group
    $ShareRules     = $Sharing.ShareRight
    $RulesNTFS      = $Sharing.RightNTFS

    Write-Host "Share Name : $ShareName"

    # =============================
    # CRÉATION DU DOSSIER
    # =============================

    if (!(Test-Path $FolderPath)) {
        New-Item -ItemType Directory -Path $FolderPath | Out-Null
        Write-Host "Dossier créé"
    }

    # =============================
    # PARTAGE SMB
    # =============================

    if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
        Remove-SmbShare -Name $ShareName -Force
        Write-Host "Partage existant supprimé"
    }

    New-SmbShare `
        -Name $ShareName `
        -Path $FolderPath `
        -FullAccess "Administrators" `
        -ChangeAccess ($ShareRules -eq "Change" ? $Group : $null) `
        -ReadAccess   ($ShareRules -eq "Read"   ? $Group : $null)

    if ($ShareRules -eq "Full") {
        Grant-SmbShareAccess -Name $ShareName -AccountName $Group -AccessRight Full -Force
    }

    Write-Host "Partage créé"

    # =============================
    # PERMISSIONS NTFS
    # =============================

    $Acl = Get-Acl $FolderPath

    $Rules = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $Group,
        $RulesNTFS,
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    $Acl.SetAccessRule($Rules)
    Set-Acl -Path $FolderPath -AclObject $Acl

    Write-Host "Permissions NTFS appliquées"
}

Write-Host "Tous les partages ont été traités avec succès"
