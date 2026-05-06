#NAME: folder_AGDLP.ps1
#AUTHOR: LE BIHAN Baptiste
#DATE: 15/12/2025
#VERSION 1.0
#Powershell version 

# Nom du script et CSV associé
$ScriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$PathCSV = "$PSScriptRoot\$ScriptName.csv"

# Vérification du CSV
if (!(Test-Path $PathCSV)) {
    Write-Error "Fichier CSV introuvable : $PathCSV"
    exit
}

# Import des règles
$Rules = Import-Csv -Path $PathCSV -Delimiter ";"

foreach ($Rule in $Rules) {

    $FolderPath  = $Rule.CheminDossier
    $Group       = $Rule.Groupe
    $RulesNTFS = $Rule.PermissionNTFS

    Write-Host "Traitement : $FolderPath → $Group ($RulesNTFS)"


# CRÉATION DU DOSSIER SI BESOIN

    if (!(Test-Path $FolderPath)) {
        New-Item -ItemType Directory -Path $FolderPath | Out-Null
        Write-Host "Dossier créé"
    }

# GESTION DES ACL NTFS


    $Acl = Get-Acl $FolderPath

    # Création de la règle NTFS
    $RulesNTFS = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $Group,
        $RulesNTFS,
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    # Application (remplace si déjà existant)
    $Acl.SetAccessRule($RulesNTFS)
    Set-Acl -Path $FolderPath -AclObject $Acl

    Write-Host "Permission NTFS appliquée"
}

Write-Host "Toutes les permissions AGDLP ont été appliquées"
