<#
  Audit Wi-Fi / Freebox - Windows - LECTURE SEULE
  Ne modifie AUCUN paramètre : il lit des infos et fait des mesures (ping, téléchargement).
  Lancement (PowerShell, dans le dossier du script) :
    powershell -ExecutionPolicy Bypass -File .\audit-wifi-windows.ps1 -Label avant
  -ExecutionPolicy Bypass ne vaut que pour cette exécution (aucun changement permanent).
#>
param(
  [string]$Label = "avant",
  [string]$Freebox = "192.168.1.254"
)
$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
$dir  = Join-Path $root "resultats"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$out  = Join-Path $dir ("audit-windows-" + $Label + "-" + (Get-Date -Format 'yyyyMMdd-HHmm') + ".txt")

function Log([string]$s) { $s | Out-File -FilePath $out -Append -Encoding utf8; Write-Host $s }
function Run([string]$title, [scriptblock]$block) {
  Log ""; Log ("===== " + $title + " =====")
  try { Log ((& $block 2>&1 | Out-String -Width 250).TrimEnd()) } catch { Log ("ERREUR : " + $_) }
}

Log ("Audit Wi-Fi - label=" + $Label + " - " + (Get-Date))

Run "Systeme" { Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version | Format-List }
Run "Cartes reseau" { Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress | Format-Table -AutoSize }
Run "Interface Wi-Fi (signal, canal, bande, debits de liaison)" { netsh wlan show interfaces }
Run "Capacites de la carte Wi-Fi (types radio / bandes supportees)" { netsh wlan show drivers }
Run "Reseaux Wi-Fi visibles (interferences / occupation des canaux)" { netsh wlan show networks mode=bssid }
Run "Configuration IP" { ipconfig /all }
Run "Passerelle par defaut" { Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object InterfaceAlias, NextHop, RouteMetric | Format-Table -AutoSize }
Run "Table ARP (appareils vus sur le reseau local)" { arp -a }

# Suivi du signal pendant 30 s
Log ""; Log "===== Suivi du signal Wi-Fi (15 echantillons / 2 s) ====="
for ($i = 1; $i -le 15; $i++) {
  $l = netsh wlan show interfaces | Select-String -Pattern '%|Mbit|Canal|Channel|BSSID' | ForEach-Object { $_.Line.Trim() }
  Log ("[" + $i + "] " + ($l -join ' | '))
  Start-Sleep -Seconds 2
}

$gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1).NextHop
if (-not $gw) { $gw = $Freebox }
Run ("Ping passerelle " + $gw + " (latence/pertes du lien Wi-Fi local, 50 paquets)") { ping -n 50 $gw }
if ($gw -ne $Freebox) { Run ("Ping Freebox " + $Freebox) { ping -n 20 $Freebox } }
Run "Ping Internet 1.1.1.1 (30 paquets)" { ping -n 30 1.1.1.1 }
Run "Ping free.fr (DNS + Internet)" { ping -n 10 free.fr }
Run "Traceroute vers 1.1.1.1" { tracert -d -h 8 1.1.1.1 }

# Tests de debit (Cloudflare) via curl.exe (inclus dans Windows 10/11)
Log ""; Log "===== Debit descendant (3 x 10 Mo) ====="
$curl = Get-Command curl.exe -ErrorAction SilentlyContinue
for ($i = 1; $i -le 3; $i++) {
  if ($curl) {
    $r = & curl.exe -s -o NUL -w "%{speed_download} %{time_total}" "https://speed.cloudflare.com/__down?bytes=10000000"
    $p = $r -split ' '
    Log ("Essai " + $i + " : " + [math]::Round([double]$p[0] * 8 / 1e6, 2) + " Mbit/s (" + $p[1] + " s)")
  } else {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $d = (New-Object Net.WebClient).DownloadData("https://speed.cloudflare.com/__down?bytes=10000000")
    $sw.Stop(); Log ("Essai " + $i + " : " + [math]::Round($d.Length * 8 / 1e6 / $sw.Elapsed.TotalSeconds, 2) + " Mbit/s")
  }
}
Log ""; Log "===== Debit montant (1 Mo) ====="
if ($curl) {
  $tmp = Join-Path $env:TEMP "upload-test.bin"
  [IO.File]::WriteAllBytes($tmp, (New-Object byte[] 1000000))
  $r = & curl.exe -s -o NUL -w "%{speed_upload}" --data-binary "@$tmp" "https://speed.cloudflare.com/__up"
  Log ("Montant : " + [math]::Round([double]$r * 8 / 1e6, 2) + " Mbit/s")
  Remove-Item $tmp -ErrorAction SilentlyContinue
}
Log ""; Log ("Termine. Fichier : " + $out)
