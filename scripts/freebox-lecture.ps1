<#
  Lecture de la Freebox via l'API Freebox OS : LECTURE SEULE (uniquement des requêtes GET après la connexion).
  - Au 1er lancement, une demande d'autorisation est envoyée à la box. Il faut la VALIDER dans l'app Freebox Connect
    (ou dans Freebox OS) dans les 4 minutes.
  - Le jeton d'application est stocké HORS du dépôt : %LOCALAPPDATA%\audit-wifi-freebox\app_token.json
  - Les clés Wi-Fi et les mots de passe sont retirés de la sortie avant écriture.
  Lancement : powershell -ExecutionPolicy Bypass -File .\scripts\freebox-lecture.ps1
#>
param([string]$Base = "http://mafreebox.freebox.fr/api/v8")
$ErrorActionPreference = 'Stop'
$appId = "fr.audit.wifi.lecture"
$tokDir = Join-Path $env:LOCALAPPDATA "audit-wifi-freebox"
$tokFile = Join-Path $tokDir "app_token.json"
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root ("resultats\freebox-lecture-" + (Get-Date -Format 'yyyyMMdd-HHmm') + ".json")

function Api($method, $path, $body = $null, $headers = @{}) {
  $p = @{ Method = $method; Uri = "$Base$path"; Headers = $headers; TimeoutSec = 15 }
  if ($body) { $p.Body = ($body | ConvertTo-Json -Compress); $p.ContentType = 'application/json' }
  try { Invoke-RestMethod @p } catch {
    $resp = $_.ErrorDetails.Message
    if ($resp) { try { return ($resp | ConvertFrom-Json) } catch {} }
    return [pscustomobject]@{ success = $false; error_code = 'http_error'; msg = $_.Exception.Message }
  }
}

# Retire récursivement tout champ sensible
$sensitive = '^(key|wpa_key|psk|password|passphrase|wep_key|secret|app_token|session_token|private_key)$'
function Clean($o) {
  if ($null -eq $o) { return $null }
  if ($o -is [System.Array]) { return @($o | ForEach-Object { Clean $_ }) }
  if ($o -is [pscustomobject]) {
    $n = [ordered]@{}
    foreach ($pr in $o.PSObject.Properties) {
      if ($pr.Name -match $sensitive) { $n[$pr.Name] = '***retiré***' } else { $n[$pr.Name] = Clean $pr.Value }
    }
    return [pscustomobject]$n
  }
  return $o
}

# 1. Jeton d'application (autorisation une seule fois)
New-Item -ItemType Directory -Force -Path $tokDir | Out-Null
if (-not (Test-Path $tokFile)) {
  $a = Api POST "/login/authorize/" @{ app_id = $appId; app_name = "Audit Wi-Fi (lecture)"; app_version = "1.0"; device_name = $env:COMPUTERNAME }
  if (-not $a.success) { Write-Host "Demande d'autorisation refusée : $($a.error_code) $($a.msg)"; exit 1 }
  $track = $a.result.track_id
  Write-Host ">>> Demande d'autorisation envoyée. VALIDEZ-LA dans l'app Freebox Connect (ou Freebox OS)."
  $status = 'pending'
  for ($i = 0; $i -lt 48 -and $status -eq 'pending'; $i++) {
    Start-Sleep -Seconds 5
    $status = (Api GET "/login/authorize/$track").result.status
  }
  Write-Host "Statut de l'autorisation : $status"
  if ($status -ne 'granted') { exit 2 }
  @{ app_token = $a.result.app_token } | ConvertTo-Json | Set-Content -Encoding utf8 $tokFile
}
$appToken = (Get-Content $tokFile -Raw | ConvertFrom-Json).app_token

# 2. Ouverture de session
$challenge = (Api GET "/login/").result.challenge
$h = New-Object System.Security.Cryptography.HMACSHA1 (,[Text.Encoding]::ASCII.GetBytes($appToken))
$pwd = -join ($h.ComputeHash([Text.Encoding]::ASCII.GetBytes($challenge)) | ForEach-Object { $_.ToString('x2') })
$s = Api POST "/login/session/" @{ app_id = $appId; password = $pwd }
if (-not $s.success) { Write-Host "Session refusée : $($s.error_code) $($s.msg)"; exit 3 }
$hdr = @{ 'X-Fbx-App-Auth' = $s.result.session_token }
Write-Host ("Session ouverte. Droits : " + (($s.result.permissions.PSObject.Properties | Where-Object Value | ForEach-Object Name) -join ', '))

# 3. Lectures (GET uniquement)
$data = [ordered]@{ date = (Get-Date).ToString('s'); permissions = $s.result.permissions }
$paths = '/connection/', '/connection/xdsl/', '/connection/config/', '/wifi/config/', '/wifi/state/', '/wifi/ap/', '/wifi/bss/', '/wifi/planning/', '/lan/config/', '/dhcp/config/', '/lan/browser/interfaces/', '/system/'
foreach ($p in $paths) { $data[$p] = (Api GET $p $null $hdr) }
foreach ($ap in @($data['/wifi/ap/'].result)) {
  if ($null -eq $ap) { continue }
  $data["/wifi/ap/$($ap.id)/allowed_channel_comb/"] = (Api GET "/wifi/ap/$($ap.id)/allowed_channel_comb/" $null $hdr)
  $data["/wifi/ap/$($ap.id)/stations/"] = (Api GET "/wifi/ap/$($ap.id)/stations/" $null $hdr)
  $data["/wifi/ap/$($ap.id)/neighbors/"] = (Api GET "/wifi/ap/$($ap.id)/neighbors/" $null $hdr)
  $data["/wifi/ap/$($ap.id)/channel_usage/"] = (Api GET "/wifi/ap/$($ap.id)/channel_usage/" $null $hdr)
}
$data['/lan/browser/pub/'] = (Api GET "/lan/browser/pub/" $null $hdr)

# Fermeture de session
Api POST "/login/logout/" $null $hdr | Out-Null

(Clean ([pscustomobject]$data)) | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 $out
Write-Host "Termine. Fichier : $out"
foreach ($k in $data.Keys) { if ($data[$k] -and $data[$k].PSObject.Properties['success'] -and -not $data[$k].success) { Write-Host "  $k -> $($data[$k].error_code)" } }
