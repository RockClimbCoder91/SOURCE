# Import the Active Directory module
Import-Module ActiveDirectory

# Define the domain components
$domainComponents = "DC=consultingfirm,DC=com"

# List all OUs under the domain
$allOUs = Get-ADOrganizationalUnit -Filter * -SearchBase $domainComponents
$allOUs | ForEach-Object {
    Write-Output "OU Name: $($_.Name)"
    Write-Output "DistinguishedName: $($_.DistinguishedName)"
    Write-Output "--------------------"
}