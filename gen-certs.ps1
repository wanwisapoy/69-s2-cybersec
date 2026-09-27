$ErrorActionPreference = 'Stop'

# Regenerates the self-signed dev TLS certificates for the PostgreSQL service.
# Requires Docker (uses a throwaway postgres:17 image that bundles OpenSSL).
#
# For production, replace these with real certificates (e.g. from a public CA).

$root = Split-Path -Parent $PSScriptRoot
$certs = Join-Path $root 'certs'
New-Item -ItemType Directory -Force -Path $certs | Out-Null

docker run --rm -v "${certs}:/certs" postgres:17 openssl req -new -x509 -nodes -days 825 `
  -subj "/CN=localhost" `
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" `
  -keyout "/certs/server.key" -out "/certs/server.crt"

if ($LASTEXITCODE -eq 0) {
    Write-Output "Generated $certs\server.crt and $certs\server.key"
} else {
    Write-Error 'Certificate generation failed.'
}