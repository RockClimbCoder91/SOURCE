# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name
$ouName = "Finance"
$ouPath = "OU=$ouName,DC=yourdomain,DC=com"  # Replace with your domain components

# Check if the OU exists
$ouExists = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -ErrorAction SilentlyContinue

if ($ouExists) {
    # OU exists
    Write-Output "The Organizational Unit (OU) named '$ouName' exists."

    # Delete the OU
    Remove-ADOrganizationalUnit -Identity $ouPath -Confirm:$false
    Write-Output "The Organizational Unit (OU) named '$ouName' has been deleted."
} else {
    # OU does not exist
    Write-Output "The Organizational Unit (OU) named '$ouName' does not exist."
}