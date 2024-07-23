#Geno Pickerign - 000816898

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name and path
$ouName = "Finance"
$ouPath = "OU=Finance,DC=example,DC=com"

# Check if the OU exists
$ouExists = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -ErrorAction SilentlyContinue

if ($ouExists) {
    # OU exists, so delete it
    Remove-ADOrganizationalUnit -Identity $ouPath -Confirm:$false
    Write-Output "The OU 'Finance' existed and has been deleted."
} else {
    # OU does not exist
    Write-Output "The OU 'Finance' does not exist."
}