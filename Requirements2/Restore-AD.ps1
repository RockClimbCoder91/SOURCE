# # Import the Active Directory module
# Import-Module ActiveDirectory

# # Define the domain components
# $domainComponents = "DC=consultingfirm,DC=com"

# # List all OUs under the domain
# $allOUs = Get-ADOrganizationalUnit -Filter * -SearchBase $domainComponents
# $allOUs | ForEach-Object {
#     Write-Output "OU Name: $($_.Name)"
#     Write-Output "DistinguishedName: $($_.DistinguishedName)"
#     Write-Output "--------------------"
# }


# Import the Active Directory module
Import-Module ActiveDirectory

# Define the domain components
$domainComponents = "DC=consultingfirm,DC=com"
$ouName = "Finance"

# Check if the OU exists
Write-Output "Checking for the existence of the Organizational Unit (OU) named '$ouName'..."
$ou = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $domainComponents -ErrorAction SilentlyContinue

if ($ou) {
    Write-Output "The Organizational Unit (OU) named '$ouName' exists."
    Write-Output "Distinguished Name: $($ou.DistinguishedName)"
} else {
    Write-Output "The Organizational Unit (OU) named '$ouName' does not exist."
}
