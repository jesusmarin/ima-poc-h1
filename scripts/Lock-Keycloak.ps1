param([string]$Tag = 'quay.io/keycloak/keycloak:26.8.1')
$ErrorActionPreference = 'Stop'
$base = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$local = Join-Path $base '.local'
New-Item -ItemType Directory -Force -Path $local | Out-Null
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Docker no esta instalado o no esta en PATH.' }
& docker pull $Tag
if ($LASTEXITCODE -ne 0) { throw "No fue posible descargar $Tag" }
$raw = & docker image inspect $Tag --format '{{json .RepoDigests}}'
if ($LASTEXITCODE -ne 0) { throw 'No fue posible inspeccionar la imagen.' }
$digests = @($raw | ConvertFrom-Json)
$selected = $digests | Where-Object { $_ -match '^quay.io/keycloak/keycloak@sha256:[a-f0-9]{64}$' } | Select-Object -First 1
if (-not $selected) { throw 'No se pudo establecer RepoDigest inmutable. No se autoriza H1.' }
[System.IO.File]::WriteAllLines((Join-Path $local 'images.env'), @("KEYCLOAK_IMAGE=$selected"), (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Imagen fijada por digest en .local/images.env: $selected"
