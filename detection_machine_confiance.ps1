# Extrait Diag_PC / DiagIdentification : détection du type de machine
# avec score de confiance et priorité des sources.
# Le module classe un poste Tiny / tout-en-un / fixe / portable en
# croisant châssis (CIM), modèle normalisé et BIOS, puis ne demande
# une confirmation à l'opérateur QUE si le score est insuffisant.
# Chaque confirmation est loggée : le journal sert à affiner la détection.

$DetectionPriority = @{
    'User'          = 0   # confirmation opérateur : la plus fiable
    'Chassis'       = 3   # Win32_SystemEnclosure.ChassisTypes
    'Model'         = 4   # modèle normalisé (ex. Lenovo M710q -> Tiny)
    'Fallback'      = 5
}

function Get-MachineDetection {
    $Ctx = @{
        MachineType     = 'Inconnu'
        IsTiny          = $false
        DetectionSource = 'Inconnu'
        ConfidenceScore = 0
        Reason          = @()
    }

    $computer  = Get-CimInstance Win32_ComputerSystem
    $enclosure = Get-CimInstance Win32_SystemEnclosure
    $chassis   = @($enclosure.ChassisTypes | Where-Object { $null -ne $_ })

    $model        = $computer.Model.Trim()
    $manufacturer = $computer.Manufacturer.Trim()
    $normalizedModel = ($model -replace '[^a-zA-Z0-9]', '').ToUpper()

    # 1. Portables : critère dur, pas de question à poser
    if ($chassis -contains 8 -or $chassis -contains 9 -or $chassis -contains 10) {
        $Ctx.MachineType = 'PC Portable'
        $Ctx.DetectionSource = 'Chassis'
        $Ctx.ConfidenceScore = 5
        $Ctx.Reason += 'Châssis portable'
        return $Ctx
    }

    # 2. Scoring progressif (tout-en-un)
    if ($chassis -contains 13 -or $chassis -contains 15) {
        $Ctx.ConfidenceScore += 3 ; $Ctx.Reason += 'Châssis AIO'
        $Ctx.DetectionSource = 'Chassis'
    }
    if ($normalizedModel -match 'M\d{3}Z') {   # séries tout-en-un Lenovo
        $Ctx.ConfidenceScore += 4 ; $Ctx.Reason += 'Modèle AIO série Z'
        $Ctx.DetectionSource = 'Model'
    }
    if ($Ctx.ConfidenceScore -ge 6) { $Ctx.MachineType = 'Tout-en-un (AIO)' }

    # 3. Mini-PC : modèle normalisé (exemple Lenovo Tiny MxxxQ)
    if ($Ctx.MachineType -eq 'Inconnu' -and
        $manufacturer -match 'LENOVO' -and $normalizedModel -match '^M\d{3}Q$') {
        $Ctx.MachineType = 'Tiny / Mini PC'
        $Ctx.IsTiny = $true
        $Ctx.ConfidenceScore = 5
        $Ctx.Reason += 'Lenovo Tiny (MxxxQ)'
        $Ctx.DetectionSource = 'Model'
    }

    # 4. Score insuffisant -> confirmation guidée de l'opérateur
    #    (valeurs au-dessus de 4 : détection autonome acceptée)
    # La confirmation remplace la détection et est journalisée dans un
    # log d'apprentissage (date; série; fabricant; modèle; type retenu).

    return $Ctx
}
