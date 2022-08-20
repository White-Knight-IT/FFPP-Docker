Param
(
    [Parameter(Mandatory = $false)]
    [switch]$ConfigurePreconsent,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true)]
    [string]$TenantId
)

$ErrorActionPreference = "Stop"

# Check if the Az PowerShell module has already been loaded.

if ( ! ( Get-Module Az ) ) { # Check if the Az PowerShell module is installed.
if ( Get-Module -ListAvailable -Name Az ) { # The Az PowerShell module is not load and it is installed. This module # must be loaded for other operations performed by this script.
Write-Host -ForegroundColor Green "Loading the Az PowerShell module..."
Import-Module Az
} else {
Install-Module Az
}
}

try {
Write-Host -ForegroundColor Green "When prompted please open a browser window and sign in using the Global Administrator account on your tenant (Probably you made a Global Admin exclusively for use by FFPP? You should do so as you can exclude it from Conditional Access policies and such.)"

Connect-AzAccount -Tenant $TenantId -UseDeviceAuthentication

} catch [Microsoft.Azure.Common.Authentication.AadAuthenticationCanceledException] { # The authentication attempt was canceled by the end-user. Execution of the script should be halted.
Write-Host -ForegroundColor Yellow "The authentication attempt was canceled. Execution of the script will be halted..."
Exit
} catch { # An unexpected error has occurred. The end-user should be notified so that the appropriate action can be taken.
Write-Error "An unexpected error has occurred. Please review the following error message and try again." `
"$($Error[0].Exception)"
}

$adAppAccess = @{
ResourceAppId = "00000002-0000-0000-c000-000000000000";
ResourceAccess =
@{
Id = "5778995a-e1bf-45b8-affa-663a9f3f4d04";
Type = "Role"},
@{
Id = "a42657d6-7f20-40e3-b6f0-cee03008a62a";
Type = "Scope"},
@{
Id = "311a71cc-e848-46a1-bdf8-97ff7156d8e6";
Type = "Scope"}
}

$graphAppAccess = @{
ResourceAppId = "00000003-0000-0000-c000-000000000000";
ResourceAccess =
@{
Id = "bf394140-e372-4bf9-a898-299cfc7564e5";
Type = "Role"},
@{
Id = "7ab1d382-f21e-4acd-a863-ba3e13f7da61";
Type = "Role"},
@{
Id = "06b708a9-e830-4db3-a914-8e69da51d44f";
Type = "Role"},
@{
Id = "84bccea3-f856-4a8a-967b-dbe0a3d53a64";
Type = "Scope"},
@{
Id = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9";
Type = "Role"}
}

$partnerCenterAppAccess = @{
ResourceAppId = "fa3d9a0c-3fb0-42cc-9193-47c7ecd2edbd";
ResourceAccess =
@{
Id = "1cebfa2a-fb4d-419e-b5f9-839b4383e05a";
Type = "Scope"}
}

Write-Host -ForegroundColor Green "Creating the Azure AD application and related resources..."

$app = New-AzADApplication -SigninAudience AzureADMultipleOrgs -DisplayName $DisplayName -RequiredResourceAccess  $graphAppAccess -ReplyUrls @("https://localhost:7074","urn:ietf:wg:oauth:2.0:oob","https://login.microsoftonline.com/organizations/oauth2/nativeclient","https://localhost","http://localhost","http://localhost:8400")

write-host -ForegroundColor Green "Application: "
write-host $app

$password = New-AzADAppCredential -ObjectId $app.id

write-host -ForegroundColor Green  "App Password: "
write-host $password

$spn = New-AzADServicePrincipal -ApplicationId $app.appId

write-host -ForegroundColor Green "Service Principal: "
write-host $spn

$adminAgentsGroup = Get-AzADGroup -DisplayName "AdminAgents"

write-host -ForegroundColor Green "AdminAgents Group: "
write-host $adminAgentsGroup

Add-AzADGroupMember -TargetGroupObject $adminAgentsGroup -MemberObjectId $spn.id

write-host "Installing PartnerCenter Module." -ForegroundColor Green
install-module PartnerCenter -Force
write-host "Sleeping for 30 seconds to allow app creation on O365" -foregroundcolor green
start-sleep 30
write-host "Please approve General consent form." -ForegroundColor Green
$PasswordToSecureString = $password.value | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($($app.AppId),$PasswordToSecureString)
$token = New-PartnerAccessToken -ApplicationId "$($app.AppId)" -Scopes 'https://api.partnercenter.microsoft.com/user_impersonation' -ServicePrincipal -Credential $credential -Tenant $($spn.AppOwnerTenantID) -UseAuthorizationCode
write-host "Please approve Exchange consent form." -ForegroundColor Green
$Exchangetoken = New-PartnerAccessToken -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716' -Scopes 'https://outlook.office365.com/.default' -Tenant $($spn.AppOwnerTenantID) -UseDeviceAuthentication
write-host "Last initation required: Please browse to https://login.microsoftonline.com/$($spn.AppOwnerTenantID)/adminConsent?client_id=$($app.AppId)"
write-host "Press any key after auth. An error report about incorrect URIs is expected!"
[void][system.console]::ReadKey($true)
Write-Host "================ Secrets ================"
Write-Host "`$ApplicationId = $($app.AppId)"
Write-Host "`$ApplicationSecret = $($password.Value)" 
Write-Host "`$TenantID = $($spn.AppOwnerTenantID)"
write-host "`$RefreshToken = $($token.refreshtoken)" -ForegroundColor Blue
write-host "`$Exchange RefreshToken = $($ExchangeToken.Refreshtoken)" -ForegroundColor Green
Write-Host "================ Secrets ================"
Write-Host " SAVE THESE IN A SECURE LOCATION "