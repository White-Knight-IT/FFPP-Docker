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
  Remove-Item "../shared_persistent_volume/device.id.token"
}
catch {}

$deviceId | Out-File -FilePath "../shared_persistent_volume/device.id.token"
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
Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d";
Type = "Scope"}
}

Write-Host -ForegroundColor Green @"
Creating the Azure AD application and related resources...

"@

$app = New-AzADApplication -SigninAudience AzureADMultipleOrgs -DisplayName $DisplayName -RequiredResourceAccess $graphAppAccess -ReplyUrls @("https://localhost:7074","urn:ietf:wg:oauth:2.0:oob","https://login.microsoftonline.com/organizations/oauth2/nativeclient","https://localhost","http://localhost","http://localhost:8400")
$password = New-AzADAppCredential -ObjectId $app.id
$spn = New-AzADServicePrincipal -ApplicationId $app.appId

$adminAgentsGroup = Get-AzADGroup -DisplayName "AdminAgents"

Add-AzADGroupMember -TargetGroupObject $adminAgentsGroup -MemberObjectId $spn.id

write-host -ForegroundColor Green @"

Waiting 20 seconds for app to propagate across Azure AD...

"@
start-sleep 20
write-warning "Please copy below cyan link into a browser window and sign in using your Global Administrator:"
write-host -ForegroundColor Cyan @"

https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&resource=https%3A%2F%2Fgraph.microsoft.com&client_id=$($app.appId)&redirect_uri=https%3A%2F%2Febay.com.au
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
  Remove-Item "../shared_persistent_volume/bootstrap.json"
}
catch {}

try {
  $bootstrapCreds | ConvertTo-Json | Add-Content  -Path "../shared_persistent_volume/bootstrap.json"
  write-host -ForegroundColor Green @"
bootstrap.json successfully created.

"@
}
catch {
  write-host -ForegroundColor Red "bootstrap.json creation failed. Please review the following error message and try again. $($Error[0])"
}
