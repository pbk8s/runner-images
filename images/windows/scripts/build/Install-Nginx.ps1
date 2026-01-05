################################################################################
##  File:  Install-Nginx.ps1
##  Desc:  Install Nginx
################################################################################

# Stop w3svc service
#Stop-Service -Name w3svc ##(Don't uncomment this line)

# Install latest nginx in chocolatey
$installDir = "C:\tools"
Install-ChocoPackage nginx -ArgumentList "--force", "--params", "/installLocation:$installDir /port:80"

# Stop and disable Nginx service
Stop-Service -Name nginx
Set-Service -Name nginx -StartupType Disabled

# Start w3svc service
#Start-Service -Name w3svc ##(Don't uncomment this line)

# Invoke Pester Tests
Invoke-PesterTests -TestFile "Nginx"
