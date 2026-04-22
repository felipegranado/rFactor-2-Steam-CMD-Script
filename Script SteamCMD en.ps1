Set-Culture en-US

# ⚙️ CONFIG — Enter the SteamCMD root folder
$global:Root = "C:\SteamCMD"
$global:RF2 = "$Root\steamapps\common\rFactor 2 Dedicated Server"

# Other variables
$global:Steam = "$Root\steamcmd.exe"
$global:ModMgr = "$RF2\Bin64\ModMgr.exe"
$global:Workshop = "$Raiz\steamapps\workshop\content\365960"


#-----
# Keep ID content separated by comma
$ContentID = Read-Host "Enter the IDs you want (separated by comma)"

Write-Host "`nWhat do you want to do with the files after installation?"
Write-Host " [0] Keep all"
Write-Host " [1] Keep only .rfcmp and .rfmod files"
Write-Host " [2] Delete all"
$Remove = Read-Host "Choose..."


#-----
# Loop to create the Steam Download Content command
$listaID = New-Object System.Collections.Generic.List[string]

$ContentID = $ContentID -split "," | ForEach-Object { $_.Trim() }

$ContentID | ForEach-Object {

   $_ = $_.Trim()

   $listaID.Add("+workshop_download_item 365960 $_")
}

# Command to download user-informed content (using the Loop result to create a single steamcmd.exe command line)

& $Steam +login anonymous $listaID +quit


# Loop through and install only subfolders matching the informed IDs
$arquivos = Get-ChildItem $Workshop -Directory | Where-Object { $_.Name -in $ContentID } | ForEach-Object {
    Get-ChildItem $_.FullName -Recurse -File | Where-Object { $_.Extension -eq ".rfcmp" }
}

foreach ($arquivo in $arquivos) {

    cd $RF2

    & $ModMgr -i"""$($arquivo.Name)""" -p"""$($arquivo.DirectoryName)""" -d"$RF2" 2>&1

    Pause
}


# Remove files based on user choice
if ($Remove -eq 1) {
    $deletarOutros = Get-ChildItem $Workshop -Recurse -File | Where-Object { $_.Extension -ne ".rfcmp" -and $_.Extension -ne ".rfmod" }
    if ($deletarOutros.Count -gt 0) { Remove-Item $deletarOutros.FullName }
}

if ($Remove -eq 2) {
    Get-ChildItem $Workshop -Directory | Where-Object { $_.Name -in $ContentID } | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
    }
}
