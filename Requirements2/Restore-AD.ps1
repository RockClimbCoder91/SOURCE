<<<<<<< HEAD
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
=======
# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name and domain components
$ouName = "Finance"
$domainComponents = "DC=consultingfirm,DC=com"
>>>>>>> 560ee61ba19fb73395a0fc5b8821f38a228918c7

# Check if the OU exists
Write-Output "Checking for the existence of the Organizational Unit (OU) named '$ouName'..."
$ou = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $domainComponents -ErrorAction SilentlyContinue

if ($ou) {
    Write-Output "The Organizational Unit (OU) named '$ouName' exists."
    Write-Output "Distinguished Name: $($ou.DistinguishedName)"
<<<<<<< HEAD
=======
    
    try {
        # Retrieve the DistinguishedName of the OU
        $ouPath = $ou.DistinguishedName

        # Retrieve all child objects within the OU
        $childObjects = Get-ADObject -Filter * -SearchBase $ouPath

        # Remove all child objects
        foreach ($child in $childObjects) {
            Remove-ADObject -Identity $child.DistinguishedName -Confirm:$false -Recursive
        }

        # Delete the OU
        Remove-ADOrganizationalUnit -Identity $ouPath -Confirm:$false
        Write-Output "The Organizational Unit (OU) named '$ouName' has been deleted."
    } catch {
        Write-Output "Failed to delete the Organizational Unit (OU) named '$ouName'. Error: $_"
    }
>>>>>>> 560ee61ba19fb73395a0fc5b8821f38a228918c7
} else {
    Write-Output "The Organizational Unit (OU) named '$ouName' does not exist."
}
