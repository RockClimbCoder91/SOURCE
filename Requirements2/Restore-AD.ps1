# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name and domain components
$ouName = "Finance"
$domainComponents = "DC=consultingfirm,DC=com"

# Function to remove all child objects within the OU
function Remove-ChildObjects($ouPath) {
    $childObjects = Get-ADObject -Filter * -SearchBase $ouPath
    foreach ($child in $childObjects) {
        Remove-ADObject -Identity $child.DistinguishedName -Confirm:$false -Recursive
    }
}

# Check if the OU exists
Write-Output "Checking for the existence of the Organizational Unit (OU) named '$ouName'..."
$ou = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $domainComponents -ErrorAction SilentlyContinue

if ($ou) {
    Write-Output "The Organizational Unit (OU) named '$ouName' exists."
    Write-Output "Distinguished Name: $($ou.DistinguishedName)"
    
    try {
        # Retrieve the DistinguishedName of the OU
        $ouPath = $ou.DistinguishedName

        # Remove all child objects within the OU
        Write-Output "Removing all child objects within the OU..."
        Remove-ChildObjects -ouPath $ouPath

        # Delete the OU
        Write-Output "Deleting the Organizational Unit (OU) named '$ouName'..."
        Remove-ADOrganizationalUnit -Identity $ouPath -Confirm:$false

        # Confirm deletion
        Write-Output "The Organizational Unit (OU) named '$ouName' has been successfully deleted."

    } catch {
        if ($_.Exception.Message -like "*Directory object not found*") {
            Write-Output "The Organizational Unit (OU) named '$ouName' was already deleted."
        } else {
            Write-Output "An unexpected error occurred while attempting to delete the Organizational Unit (OU) named '$ouName'. Error: $_"
        }
    }

    # Exit the script after successful deletion or known expected error
    exit
} else {
    Write-Output "The Organizational Unit (OU) named '$ouName' does not exist."
}

#End of script to prevent any further checks or actions
exit
