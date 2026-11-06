$ErrorActionPreference='Stop'
$base=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
python (Join-Path $base 'tests/discovery_probe.py') --issuer 'http://localhost:18080/realms/master' --out (Join-Path $base 'evidence/keycloak/p01')
if ($LASTEXITCODE -ne 0) { throw 'P01 discovery fallido.' }
