<# Deploy Sabor Goiano na Vercel — funciona aqui (agente) e no seu PowerShell.
   Uso:
     .\deploy.ps1 -Prod            # deploy produção (precisa VERCEL_TOKEN ou login prévio)
     $env:VERCEL_TOKEN="xxx"; .\deploy.ps1 -Prod
#>
param([switch]$Prod, [switch]$Preview)

$ErrorActionPreference = "Stop"
$env:VERCEL_TELEMETRY_DISABLED = "1"

function Check-Cmd($name) {
  $c = Get-Command $name -ErrorAction SilentlyContinue
  if (-not $c) { Write-Host "FALTANDO: $name" -ForegroundColor Red; return $false }
  return $true
}

Write-Host "== Sabor Goiano / Vercel deploy ==" -ForegroundColor Yellow
if (-not (Check-Cmd "node")) { Write-Host "Instale o Node LTS: https://nodejs.org"; exit 1 }
if (-not (Check-Cmd "vercel")) { Write-Host "Instalando vercel..."; npm i -g vercel }

node -v
vercel --version

Set-Location $PSScriptRoot

$tokenArgs = @()
if ($env:VERCEL_TOKEN) {
  Write-Host "Usando VERCEL_TOKEN (modo nao-interativo)." -ForegroundColor Green
  $tokenArgs = @("--token", $env:VERCEL_TOKEN)
} else {
  Write-Host "Sem VERCEL_TOKEN: vai exigir 'vercel login' interativo no seu terminal." -ForegroundColor Yellow
}

if ($Preview) {
  vercel --yes @tokenArgs
} else {
  # padrão: produção
  vercel --prod --yes @tokenArgs
}
