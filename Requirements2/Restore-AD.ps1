# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name and domain components
$ouName = "Finance"
$domainComponents = "DC=consultingfirm,DC=com"

# Check if the OU exists
$ou = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $domainComponents -ErrorAction SilentlyContinue

if ($ou) {
    Write-Output "The Organizational Unit (OU) named '$ouName' exists."
    Write-Output "Distinguished Name: $($ou.DistinguishedName)"
    
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
} else {
    Write-Output "The Organizational Unit (OU) named '$ouName' does not exist."
}