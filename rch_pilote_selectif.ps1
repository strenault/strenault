# Extrait Rch Pilote : installation sélective de pilotes via pnputil
# Principe : au lieu de réinstaller tous les pilotes d'un dossier réseau,
# l'outil compare les pilotes déjà publiés sur le poste (pnputil /enum-drivers)
# avec les .inf du dossier choisi, et n'installe QUE les pilotes manquants.
# Gain de temps sur un parc important et zéro risque d'écraser une version
# plus récente déjà en place.
# (Partage réseau, lettres de lecteur et noms de serveur : exemples génériques.)

function Get-InstalledDrivers {
    # Analyse la sortie de pnputil /enum-drivers : Published Name + Driver Version
    $output = pnputil /enum-drivers | Out-String
    $installedDrivers = @()
    $currentDriver = @{}

    $output -split "`r`n" | ForEach-Object {
        if ($_ -match "Published Name:\s*(.+)") {
            $currentDriver["Name"] = $matches[1].Trim()
        } elseif ($_ -match "Driver Version:\s*(.+)") {
            $currentDriver["Version"] = $matches[1].Trim()
            if ($currentDriver["Name"]) {
                $installedDrivers += $currentDriver
                $currentDriver = @{}
            }
        }
    }
    return $installedDrivers
}

function Install-Drivers {
    param(
        [string]$driversPath,        # ex: \\serveur\partage$\Pilotes\Windows
        [array]$installedDrivers
    )

    $infFiles = Get-ChildItem -Path $driversPath -Filter "*.inf" -File -Recurse -ErrorAction SilentlyContinue
    $updatedCount = 0; $skippedCount = 0

    foreach ($infFile in $infFiles) {
        # Nom affichable du pilote lu dans le .inf
        $content = Get-Content $infFile.FullName -Raw
        $driverName = if ($content -match "DriverPackageDisplayName\s*=\s*(.+)") {
            $matches[1].Trim()
        } else { [IO.Path]::GetFileNameWithoutExtension($infFile) }

        $isInstalled = [bool]($installedDrivers | Where-Object { $_["Name"] -eq $driverName })

        if (-not $isInstalled) {
            Start-Process -FilePath "pnputil" -ArgumentList "/add-driver `"$($infFile.FullName)`" /install" -Wait -NoNewWindow
            $updatedCount++
            Write-Host "Pilote installé : $driverName" -ForegroundColor Green
        } else {
            $skippedCount++
            Write-Host "Déjà installé, ignoré : $driverName" -ForegroundColor Yellow
        }
    }
    Write-Host "`nRésumé : $updatedCount installés, $skipp`edCount déjà présents."
}

# Flux complet :
# 1. Mappe temporairement le partage réseau des pilotes en Z: (net use, non persistant)
# 2. Boîte de dialogue de sélection du dossier modèle (ex: Z:\LENOVO\ThinkPad_L570)
# 3. Démappage immédiat, le chemin est converti en UNC pour pnputil
# 4. Confirmation, installation sélective, proposition de redémarrer si besoin
