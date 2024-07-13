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

# # Import the Active Directory module
# Import-Module ActiveDirectory

# # Define the exact DistinguishedName of the Finance OU
# $ouPath = "OU=Finance,DC=consultingfirm,DC=com"  # Replace with the exact DistinguishedName

# # Check if the OU exists
# $ou = Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction SilentlyContinue

# if ($ou) {
#     Write-Output "The Organizational Unit (OU) named 'Finance' exists."
#     Write-Output "Distinguished Name: $($ou.DistinguishedName)"
    
#     try {
#         # Retrieve all child objects within the OU
#         $childObjects = Get-ADObject -Filter * -SearchBase $ouPath

#         # Remove all child objects
#         foreach ($child in $childObjects) {
#             Remove-ADObject -Identity $child.DistinguishedName -Confirm:$false -Recursive
#         }

#         # Delete the OU
#         Remove-ADOrganizationalUnit -Identity $ouPath -Confirm:$false
#         Write-Output "The Organizational Unit (OU) named 'Finance' has been deleted."
#     } catch {
#         Write-Output "Failed to delete the Organizational Unit (OU) named 'Finance'. Error: $_"
#     }
# } else {
#     Write-Output "The Organizational Unit (OU) named 'Finance' does not exist."
# }
