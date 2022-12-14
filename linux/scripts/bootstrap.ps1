write-host -ForegroundColor Yellow @"
    ________________  ____
   / ____/ ____/ __ \/ __ \
  / /_  / /_  / /_/ / /_/ /
 / __/ / __/ / ____/ ____/
/_/   /_/   /_/   /_/

Freakin' Fast Partner Portal

Bootstrap App Creation Script

"@

$DisplayName = "FFPP Bootstrap"
$ErrorActionPreference = "Stop"
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

# Check if the Az PowerShell module has already been loaded.

if ( ! ( Get-Module Az ) ) { # Check if the Az PowerShell module is loaded.

  if ( Get-Module -ListAvailable -Name Az ) { # The Az PowerShell module is not loaded and it is installed. This module # must be loaded for other operations performed by this script.
    Write-Host -ForegroundColor Green @"
Loading the Az PowerShell module...

"@
    Import-Module Az
  }
  else {
  Write-Host -ForegroundColor Green @"
Installing the Az PowerShell module...

"@
    Install-Module Az -Force
  }
}

try {
  Write-Host -ForegroundColor Green @"
When prompted please open a browser window and sign in using the Global Administrator account on your tenant.

"@
  Connect-AzAccount -UseDeviceAuthentication
}
catch { # An unexpected error has occurred. The end-user should be notified so that the appropriate action can be taken.
  Write-Error -ForegroundColor Red "An unexpected error has occurred. Please review the following error message and try again. $($Error[0])"
  Exit
}

$deviceId=[guid]::NewGuid().ToString()

try
{
  Remove-Item "../persistent/ffpp/device.id.token"
}
catch {}

$deviceId | Out-File -FilePath "../persistent/ffpp/device.id.token"
$devicetag = $deviceId.Substring($deviceId.Length - 6)
$DisplayName = "$DisplayName - $devicetag"

$user = Get-AzADUser -SignedIn
$TenantId = $user.Mail.Split('@')[1]

$graphAppAccess = @{
ResourceAppId = "00000003-0000-0000-c000-000000000000";
ResourceAccess =
@{
Id = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9";
Type = "Role"},
@{
Id = "62a82d76-70ea-41e2-9197-370581804d09";
Type = "Role"},
@{
Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d";
Type = "Scope"},
@{
Id = "4e46008b-f24c-477d-8fff-7bb4ec7aafe0";
Type = "Scope"}
}

Write-Host -ForegroundColor Green @"
Creating the Azure AD application and related resources...

"@

$app = New-AzADApplication -SigninAudience AzureADMultipleOrgs -DisplayName $DisplayName -RequiredResourceAccess $graphAppAccess -ReplyUrls @("https://white-knight-it.github.io/FFPP","https://localhost:7074","https://localhost")
# 60 second sleep let the app propagate in Azure before creating password
start-sleep 60
Write-Host -ForegroundColor Green @"
Creating app password...

"@
$password = New-AzADAppCredential -ObjectId $app.id
start-sleep 30

write-host " "
write-warning "Please copy below cyan link into a browser window and sign in using your Global Administrator:"
write-host -ForegroundColor Cyan @"

https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&resource=https%3A%2F%2Fgraph.microsoft.com&client_id=$($app.appId)&redirect_uri=https%3A%2F%2Fwhite-knight-it.github.io%2FFFPP
"@
write-host -ForegroundColor Green @"

Press any key after you have signed in.

"@
[void][system.console]::ReadKey($true)

$aid=$app.appId
$pwd=$password.secretText

$bootstrapCreds = @{
TenantId = $TenantId
RefreshToken = "NOT_YET_OBTAINED"
ExchangeRefreshToken = "NOT_YET_OBTAINED"
ApplicationId = $aid
ApplicationSecret = $pwd
}

try
{
  Remove-Item "../persistent/ffpp/bootstrap.json"
}
catch {}

try {
  $bootstrapCreds | ConvertTo-Json | Add-Content  -Path "../persistent/ffpp/bootstrap.json"
  write-host -ForegroundColor Green @"
bootstrap.json successfully created.

"@
}
catch {
  write-host -ForegroundColor Red "bootstrap.json creation failed. Please review the following error message and try again. $($Error[0])"
}
