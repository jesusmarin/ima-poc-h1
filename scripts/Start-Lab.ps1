$ErrorActionPreference = 'Stop'
$base=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$envPath=Join-Path $base '.local/lab.env'
$imagePath=Join-Path $base '.local/images.env'
if (-not (Test-Path $envPath)) { throw 'Ejecute Initialize-Lab.ps1 primero.' }
if (-not (Test-Path $imagePath)) { throw 'Ejecute Lock-Keycloak.ps1 primero.' }
$combined=Join-Path $base '.local/compose.env'
[System.IO.File]::WriteAllLines($combined, @((Get-Content $envPath) + (Get-Content $imagePath)), (New-Object System.Text.UTF8Encoding($false)))
Push-Location $base
try {
 & docker compose --env-file $combined -f compose.yaml config --quiet
 if ($LASTEXITCODE -ne 0) { throw 'Compose config fallido.' }
 & docker compose --env-file $combined -f compose.yaml up -d
 if ($LASTEXITCODE -ne 0) { throw 'Fallo de arranque Docker Compose.' }
 Write-Host 'Laboratorio en http://localhost:18080 — espere disponibilidad y ejecute Test-Discovery.ps1.'
} finally {Pop-Location}
