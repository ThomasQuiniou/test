# Vérifier si le script est exécuté en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Si pas exécuté en tant qu'administrateur, relancer PowerShell avec des privilèges administratifs
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Utiliser le chemin de %USERPROFILE% pour plus de flexibilité
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$certPath = Join-Path $scriptDir "certificate.p12"
$certPassword = "" # Laissez vide si pas de mot de passe, sinon mettez le mot de passe ici

# Fonction pour modifier temporairement les paramètres de sécurité
function Set-SecurityPolicy($enable) {
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if ($enable) {
        Set-ItemProperty -Path $key -Name "EnableLUA" -Value 0
        Set-ItemProperty -Path $key -Name "ConsentPromptBehaviorAdmin" -Value 0
    } else {
        Set-ItemProperty -Path $key -Name "EnableLUA" -Value 1
        Set-ItemProperty -Path $key -Name "ConsentPromptBehaviorAdmin" -Value 5
    }
}

# Définir les paramètres du serveur proxy
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer -Value '192.168.1.107:8080'

# Charger et installer le certificat
try {
    # Désactiver temporairement les paramètres de sécurité
    Set-SecurityPolicy -enable $false

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath, $certPassword)
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("ROOT", "LocalMachine")
    $store.Open("ReadWrite")
    $store.Add($cert)
    $store.Close()
}
catch {
    Write-Host "Erreur lors de l'installation du certificat."
}
finally {
    # Réactiver les paramètres de sécurité
    Set-SecurityPolicy -enable $true
}

# Fonction pour désactiver le proxy
function Disable-Proxy {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer -Value ""
    Write-Host "Proxy désactivé car l'ordinateur est en veille ou l'écran est fermé."
}

# Ajouter un gestionnaire d'événement pour la mise en veille
$null = Register-ObjectEvent -InputObject ([Microsoft.Win32.SystemEvents]) -EventName "PowerModeChanged" -SourceIdentifier "PowerModeListener" -Action {
    if ($EventArgs.Mode -eq [Microsoft.Win32.PowerModes]::Suspend) {
        Disable-Proxy
    }
}

# Maintenir le script actif pour surveiller les événements de mise en veille
exit;