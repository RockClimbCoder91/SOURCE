#Geno Pickerign - 000816898

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name
$ouName = "Finance"

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