# Extrait Get-Diagnostic : test de sortie Internet en environnement
# d'entreprise, où l'ICMP est souvent filtré et la sortie passe par un
# proxy. En deux temps : TCP 443 direct, puis requête HTTPS via le proxy
# du poste. Sans ce double test, un poste parfaitement sain derrière un
# proxy est marqué « pas de sortie Internet ».

function Test-InternetAccess {
    $adapter = Get-NetIPConfiguration |
        Where-Object { $_.IPv4Address } | Select-Object -First 1

    if (-not $adapter.IPv4DefaultGateway) {
        return [PSCustomObject]@{ Ok = $false; Via = 'aucune passerelle' }
    }

    # 1. Résolution DNS (interne)
    $dnsOk = [bool](Resolve-DnsName 'microsoft.com' -DnsOnly -ErrorAction SilentlyContinue)

    # 2. Passerelle locale (réseau)
    $gwOk = Test-Connection $adapter.IPv4DefaultGateway.NextHop -Count 1 -Quiet

    # 3. Sortie Internet directe : TCP 443 (l'ICMP est filtré en entreprise)
    $tcpOk = Test-NetConnection 1.1.1.1 -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue

    # 4. Si le TCP direct échoue : la sortie passe peut-être par le proxy
    #    du poste (WinINET) -> tester une vraie requête HTTPS.
    $proxyOk = $false
    if (-not $tcpOk) {
        try {
            $proxyOk = ((Invoke-WebRequest -Uri 'https://www.microsoft.com' `
                -UseBasicParsing -TimeoutSec 10).StatusCode -eq 200)
        } catch { $proxyOk = $false }
    }

    [PSCustomObject]@{
        DnsOk   = $dnsOk
        GwOk    = $gwOk
        TcpOk   = $tcpOk
        ProxyOk = $proxyOk
        Ok      = ($dnsOk -and $gwOk -and ($tcpOk -or $proxyOk))
        Via     = if ($proxyOk -and -not $tcpOk) { 'proxy' } else { 'direct' }
    }
}

# Autre piège du diagnostic en entreprise : un poste sans mise à jour
# récente n'est PAS en panne si les MAJ sont pilotées centralement.
# Détecter le pilotage AVANT d'alerter :

function Test-UpdateManagement {
    $wuPolicy = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -ErrorAction SilentlyContinue
    $auPolicy = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -ErrorAction SilentlyContinue
    $partOfDomain = (Get-CimInstance Win32_ComputerSystem).PartOfDomain

    if ($auPolicy.UseWUServer -eq 1 -and $wuPolicy.WUServer) { return 'WSUS' }
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Enrollments')     { return 'MDM probable (Intune)' }
    if ($wuPolicy)  { return 'WUfB / GPO' }
    if ($partOfDomain) { return 'Domaine : pilotage central probable' }
    return 'Poste autonome : vérifier Windows Update'   # seul cas d'alerte
}
