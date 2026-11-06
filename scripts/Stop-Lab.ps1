$ErrorActionPreference='Stop'
$base=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$combined=Join-Path $base '.local/compose.env'
if (-not (Test-Path $combined)) { throw 'No existe .local/compose.env; el laboratorio no fue inicializado.' }
Push-Location $base
try { & docker compose --env-file $combined -f compose.yaml down } finally { Pop-Location }
