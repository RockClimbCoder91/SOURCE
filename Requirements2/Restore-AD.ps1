#Geno Pickerign - 000816898

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name and path
$ouName = "Finance"
$ouPath = "OU=Finance,DC=consultingfirm,DC=com"
$parentPath = "DC=consultingfirm,DC=com"

# Search for the OU
$ouExists = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -ErrorAction SilentlyContinue

if ($ouExists) {
    # Remove protection from accidental deletion
    Set-ADOrganizationalUnit -Identity $ouExists.DistinguishedName -ProtectedFromAccidentalDeletion $false

    # OU exists, so delete it using its DN
    Remove-ADOrganizationalUnit -Identity $ouExists.DistinguishedName -Confirm:$false
    Write-Output "The OU 'Finance' existed and has been deleted."
} else {
    # OU does not exist
    Write-Output "The OU 'Finance' does not exist."
}

try {
    # Check if the parent container exists
    $parentExists = Get-ADOrganizationalUnit -Identity $parentPath -ErrorAction Stop

    # Create a new OU
    New-ADOrganizationalUnit -Name $ouName -Path $parentPath -ProtectedFromAccidentalDeletion $true
    Write-Output "The OU 'Finance' has been created."
} catch {
    Write-Output "Error: $_"
}