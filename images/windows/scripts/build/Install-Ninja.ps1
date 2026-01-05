# Install-Ninja-WinArm64.ps1 ## Arm64 specific Ninja installation script

$ninjaVersion = "1.13.2"
$ninjaUrl = "https://github.com/ninja-build/ninja/releases/download/v$ninjaVersion/ninja-winarm64.zip"
$zipPath = "$env:TEMP\ninja-win-arm64.zip"
$installDir = "C:\Tools\Ninja"

Write-Host "Downloading Ninja $ninjaVersion (Windows Arm64)..."
Invoke-WebRequest -Uri $ninjaUrl -OutFile $zipPath

Write-Host "Extracting to $installDir..."
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force

# Add to system PATH if not already
$pathEnv = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
if (-not ($pathEnv -split ';' | Where-Object { $_ -eq $installDir })) {
    Write-Host "Adding $installDir to system PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$pathEnv;$installDir", [EnvironmentVariableTarget]::Machine)
}

# Update PATH for current session
$env:Path += ";$installDir"

# Verify Ninja installation
$ninjaPath = Get-Command ninja.exe -ErrorAction SilentlyContinue
if ($ninjaPath) {
    Write-Host "Ninja installed at: $($ninjaPath.Source)"
    ninja --version
} else {
    Write-Host "Ninja not found in PATH. Please restart shell or check install path."
}
