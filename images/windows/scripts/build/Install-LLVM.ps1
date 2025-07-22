################################################################################
##  File:  Install-LLVM.ps1
##  Desc:  Install the latest stable version of llvm and clang compilers
################################################################################

#$llvmVersion = (Get-ToolsetContent).llvm.version
#$latestChocoVersion = Resolve-ChocoPackageVersion -PackageName "llvm" -TargetVersion $llvmVersion
#Install-ChocoPackage llvm -ArgumentList '--version', $latestChocoVersion

#Invoke-PesterTests -TestFile "LLVM"

# LLVM release info
$llvmVersion = (Get-ToolsetContent).llvm.version
$archiveName = "clang+llvm-$llvmVersion-aarch64-pc-windows-msvc.tar.xz"
$baseUrl = "https://github.com/llvm/llvm-project/releases/download/llvmorg-$llvmVersion"
$downloadUrl = "$baseUrl/$archiveName"

# Paths
$downloadPath = "$env:TEMP\$archiveName"
$installDir = "C:\Program Files\LLVM"

# Clean install directory
if (Test-Path $installDir) {
    Write-Host "Removing existing LLVM directory..."
    Remove-Item -Path $installDir -Recurse -Force
}
New-Item -ItemType Directory -Path $installDir | Out-Null

# Download LLVM binary
Write-Host "Downloading LLVM $llvmVersion..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Extract using tar (built into Windows)
Write-Host "Extracting archive..."
tar -xf $downloadPath -C $installDir

# LLVM folder is nested — detect subdirectory
$subfolder = Get-ChildItem -Path $installDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1
# Move all contents up one level if subfolder exists
if ($subfolder) {
    Write-Host "Flattening extracted LLVM directory structure..."
    Get-ChildItem -Path $subfolder.FullName | ForEach-Object {
        Move-Item -Path $_.FullName -Destination $installDir -Force
    }
    Remove-Item -Path $subfolder.FullName -Recurse -Force
}
$llvmBinPath = Join-Path $installDir "bin"

# Add LLVM bin to system PATH
$existingPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
if (-not ($existingPath -like "*$llvmBinPath*")) {
    Write-Host "Adding LLVM to system PATH..."
    $newPath = "$existingPath;$llvmBinPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
}

# Add to current session PATH
$env:Path += ";$llvmBinPath"

# Clean up downloaded archive
Remove-Item $downloadPath

# Verify installation
Write-Host "Verifying clang installation:"
& "$llvmBinPath\clang.exe" --version

Invoke-PesterTests -TestFile "LLVM"
