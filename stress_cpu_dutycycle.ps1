# Extrait StressTest_PC : stress CPU à charge cible avec scoring P90
# Principe : on ne sature pas le processeur. Un duty-cycle calibré maintient
# la charge proche d'une cible (50 %) : si la machine dérive au-dessus,
# c'est qu'un goulot matériel se cache ailleurs (RAM, disque, GPU intégré).
# Le score ne pénalise pas les pics isolés : seule la dérive SOUTENUE
# (P90 des échantillons) compte.

function Invoke-CPUStressTest {
    param(
        [int]$DurationSeconds = 60,
        [int]$TargetLoadPercent = 50
    )

    $samples = [System.Collections.Generic.List[double]]::new()
    $busyMs = 100                                              # 100 ms de calcul...
    $idleMs = [int]($busyMs * (100 / $TargetLoadPercent) - $busyMs)  # ...repos calibre la charge

    $stressEndTime = [DateTime]::Now.AddSeconds($DurationSeconds * 0.9)

    while ((Get-Date) -lt $stressEndTime) {
        # Phase ACTIVE : calcul intensif
        $watch = [System.Diagnostics.Stopwatch]::StartNew()
        while ($watch.ElapsedMilliseconds -lt $busyMs) {
            $x = 0.0
            for ($i = 1; $i -lt 100000; $i++) {
                $x += [Math]::Pow($i, 0.5) * [Math]::Sin($i * 0.1) * [Math]::Cos($i * 0.01)
            }
        }
        # Phase REPOS : le CPU respire
        Start-Sleep -Milliseconds $idleMs

        # Mesure de la charge PENDANT le stress
        $cpuLoad = (Get-CimInstance Win32_Processor).LoadPercentage
        if ($cpuLoad -is [array]) {
            $cpuLoad = ($cpuLoad | Measure-Object -Average).Average
        }
        if ($null -ne $cpuLoad -and $cpuLoad -ge 0 -and $cpuLoad -le 100) {
            $samples.Add([double]$cpuLoad)
        }
    }

    if ($samples.Count -gt 0) {
        $avgLoad = ($samples | Measure-Object -Average).Average
        $deviation = [math]::Abs($avgLoad - $TargetLoadPercent)

        # Score : proximité de la cible = CPU sain
        $score = if ($deviation -le 5)  { 100 }
                 elseif ($deviation -le 10) { 90 }
                 elseif ($deviation -le 20) { 75 }
                 elseif ($deviation -le 30) { 60 }
                 else { 40 }

        # Goulot : basé sur le P90 (un pic isolé ne compte pas)
        $sorted = $samples | Sort-Object
        $p90Index = [math]::Min($samples.Count - 1, [math]::Floor($samples.Count * 0.9))
        $p90Load = $sorted[$p90Index]

        $bottleneck = if ($p90Load -gt 85) { 'CPU_SATURATED' }
                      elseif ($avgLoad -gt 65) { 'CPU_HIGH_LOAD' }
                      elseif ($avgLoad -lt 35) { 'CPU_LOW_LOAD' }
                      else { 'OK' }

        [PSCustomObject]@{
            Score      = $score
            AverageLoad = [math]::Round($avgLoad, 1)
            P90Load    = [math]::Round($p90Load, 1)
            Bottleneck = $bottleneck
            Samples    = $samples.Count
        }
    }
}
