param([switch]$Force)
$ErrorActionPreference = 'Stop'
$base = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$local = Join-Path $base '.local'
New-Item -ItemType Directory -Force -Path $local | Out-Null
$path = Join-Path $local 'lab.env'
if ((Test-Path $path) -and -not $Force) { Write-Host "Ya existe $path; no se sobrescribio."; exit 0 }
$bytes = New-Object byte[] 36
$rng=[System.Security.Cryptography.RandomNumberGenerator]::Create()
try {$rng.GetBytes($bytes)} finally {$rng.Dispose()}
$secret=[Convert]::ToBase64String($bytes).Replace('+','A').Replace('/','B').Replace('=','')
[System.IO.File]::WriteAllLines($path, @("KC_BOOTSTRAP_ADMIN_USERNAME=iam_lab_admin", "KC_BOOTSTRAP_ADMIN_PASSWORD=$secret"), (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Credenciales sinteticas locales creadas en .local/lab.env (excluido por .gitignore). No compartir ni subir."
