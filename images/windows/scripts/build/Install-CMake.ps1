# Install-CMake-Arm64 version (Not present in the main x86 repo of runner images)

$cmakeVersion = "4.2.1"
$cmakeUrl = "https://cmake.org/files/v4.2/cmake-${cmakeVersion}-windows-arm64.msi"
$installerPath = "$env:TEMP\cmake-arm64.msi"

Write-Host "Downloading CMake $cmakeVersion for Windows Arm64..."
Invoke-WebRequest -Uri $cmakeUrl -OutFile $installerPath

Write-Host "Installing CMake silently and adding to system PATH..."
$arguments = "/i `"$installerPath`" /qn ADD_CMAKE_TO_PATH=System"
Start-Process msiexec.exe -Wait -ArgumentList $arguments

# Validate cmake is in the system PATH
$cmakePath = (Get-Command cmake.exe -ErrorAction SilentlyContinue).Source
if (-not $cmakePath) {
    # Update the PATH for current session
    $newPath = "C:\Program Files\CMake\bin"
    if (-not ($env:Path -like "*$newPath*")) {
        $env:Path += ";$newPath"
    }
    $cmakePath = (Get-Command cmake.exe -ErrorAction SilentlyContinue).Source
}

if ($cmakePath) {
    Write-Host "CMake installed at: $cmakePath"
    cmake --version

   <#  # Check if it's really ARM64
    function Get-PEArchitecture {
        param([string]$exePath)

        $fs = [System.IO.File]::OpenRead($exePath)
        $br = New-Object System.IO.BinaryReader($fs)
        $fs.Seek(0x3C, 'Begin') | Out-Null
        $peHeaderOffset = $br.ReadInt32()
        $fs.Seek($peHeaderOffset + 4, 'Begin') | Out-Null
        $machineType = $br.ReadUInt16()
        $br.Close()
        $fs.Close()

        switch ($machineType) {
            0xAA64 { return "ARM64 (AA64)" }
            0x8664 { return "x64 (AMD64)" }
            0x014c { return "x86 (Intel 386)" }
            default { return "Unknown: 0x{0:X4}" -f $machineType }
        }
    }

    $arch = Get-PEArchitecture $cmakePath
    Write-Host "Architecture check: $arch" #>
} else {
    Write-Host "CMake was not detected in PATH. Installation may have failed."
    Exit 1
}
