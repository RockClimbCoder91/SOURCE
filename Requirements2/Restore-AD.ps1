#Geno Pickerign - 000816898

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name and path
$ouName = "Finance"
$parentPath = "DC=consultingfirm,DC=com"
$ouPath = "OU=Finance,$parentPath"

# Search for the OU
$ouExists = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $parentPath -ErrorAction SilentlyContinue

if ($ouExists) {
    # Get all child objects of the OU
    $childObjects = Get-ADObject -Filter * -SearchBase $ouExists.DistinguishedName -SearchScope OneLevel

    # Remove all child objects
    foreach ($child in $childObjects) {
        Remove-ADObject -Identity $child.DistinguishedName -Confirm:$false
    }

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
    # Create a new OU
    New-ADOrganizationalUnit -Name $ouName -Path $parentPath -ProtectedFromAccidentalDeletion $true
    Write-Output "The OU 'Finance' has been created."
} catch {
    Write-Output "Error: $_"
}

# Define the path to the CSV file
$csvPath = "$PSScriptRoot\financePersonnel.csv"

# Import the CSV file
$users = Import-Csv -Path $csvPath

# Loop through each user in the CSV file and create the AD account
foreach ($user in $users) {
    $firstName = $user.First_Name
    $lastName = $user.Last_Name
    $displayName = "$firstName $lastName"
    $postalCode = $user.PostalCode
    $officePhone = $user.OfficePhone
    $mobilePhone = $user.MobilePhone
    $samAccountName = $user.samAccount
    $userPrincipalName = "$samAccountName@consultingfirm.com"
    $name = "$firstName $lastName"

    try {
        # Create the user in Active Directory
        New-ADUser `
            -GivenName $firstName `
            -Surname $lastName `
            -Name $name `
            -DisplayName $displayName `
            -PostalCode $postalCode `
            -OfficePhone $officePhone `
            -MobilePhone $mobilePhone `
            -SamAccountName $samAccountName `
            -UserPrincipalName $userPrincipalName `
            -Path $ouPath `
            -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false

        Write-Output "Created user: $displayName"
    } catch {
        Write-Output "Error creating user ${displayName}: $_"
    }
}