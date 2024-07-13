# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name
$ouName = "Finance"

# Check if the OU exists
$ouExists = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -ErrorAction SilentlyContinue

if ($ouExists) {
    # OU exists
    Write-Output "The Organizational Unit (OU) named '$ouName' exists."

    try {
        # Retrieve the DistinguishedName of the OU
        $ouPath = $ouExists.DistinguishedName

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
    # OU does not exist
    Write-Output "The Organizational Unit (OU) named '$ouName' does not exist."
}
