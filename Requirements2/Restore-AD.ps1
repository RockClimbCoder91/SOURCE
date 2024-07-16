#Geno Pickerign - 000816898

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name and domain components
$ouName = "Finance"
$domainComponents = "DC=consultingfirm,DC=com"
$csvFilePath = Join-Path -Path $PSScriptRoot -ChildPath "financePersonnel.csv"

# Function to remove all child objects within the OU
function Remove-ChildObjects($ouPath) {
    $childObjects = Get-ADObject -Filter * -SearchBase $ouPath
    foreach ($child in $childObjects) {
        Remove-ADObject -Identity $child.DistinguishedName -Confirm:$false -Recursive
    }
}

# Function to create the OU
function Create-OU($ouName, $domainComponents) {
    $ouPath = "OU=$ouName,$domainComponents"
    New-ADOrganizationalUnit -Name $ouName -Path $domainComponents
    Write-Output "The Organizational Unit (OU) named '$ouName' has been successfully created."
}

# Function to import users from CSV and add to the Finance OU
function Import-Users($csvFilePath, $ouPath) {
    $users = Import-Csv -Path $csvFilePath
    foreach ($user in $users) {
        $firstName = $user.First_Name
        $lastName = $user.Last_Name
        $displayName = "$firstName $lastName"
        $postalCode = $user.PostalCode
        $officePhone = $user.OfficePhone
        $mobilePhone = $user.MobilePhone
        $samAccountName = $user.samAccount
        $userPrincipalName = "$samAccountName@consultingfirm.com"

        # Create the user
        New-ADUser -Name $displayName -GivenName $firstName -Surname $lastName -DisplayName $displayName `
                   -UserPrincipalName $userPrincipalName -SamAccountName $samAccountName `
                   -Path $ouPath -PostalCode $postalCode -OfficePhone $officePhone `
                   -MobilePhone $mobilePhone -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
                   -Enabled $true

        Write-Output "User '$displayName' has been created and added to the OU '$ouName'."
    }
}

# Function to disable protection from accidental deletion
function Disable-DeletionProtection($ouPath) {
    $ou = Get-ADOrganizationalUnit -Identity $ouPath
    $ou | Set-ADObject -ProtectedFromAccidentalDeletion $false
    Write-Output "The Organizational Unit (OU) named '$ouName' is no longer protected from accidental deletion."
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

        # Disable deletion protection
        Disable-DeletionProtection -ouPath $ouPath

        # Remove all child objects within the OU
        Write-Output "Removing all child objects within the OU..."
        Remove-ChildObjects -ouPath $ouPath

        # Delete the OU
        Write-Output "Deleting the Organizational Unit (OU) named '$ouName'..."
        Remove-ADOrganizationalUnit -Identity $ouPath -Confirm:$false

        # Confirm deletion
        Write-Output "The Organizational Unit (OU) named '$ouName' has been successfully deleted."

    } catch {
        Write-Output "An unexpected error occurred while attempting to delete the Organizational Unit (OU) named '$ouName'. Error: $_"
        exit 1
    }
}

# Create the OU
Create-OU -ouName $ouName -domainComponents $domainComponents

# Import users from CSV
Import-Users -csvFilePath $csvFilePath -ouPath $ouPath

# Generate the output file for submission
Get-ADUser -Filter * -SearchBase "OU=Finance,DC=consultingfirm,DC=com" -Properties DisplayName,PostalCode,OfficePhone,MobilePhone | Select-Object DisplayName,PostalCode,OfficePhone,MobilePhone | Out-File -FilePath .\AdResults.txt

# End of script to prevent any further checks or actions
exit