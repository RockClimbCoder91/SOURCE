#Geno Pickerign - 000816898

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU name and domain components
$ouName = "Finance"
$domainComponents = "DC=consultingfirm,DC=com"
$csvFilePath = Join-Path -Path $PSScriptRoot -ChildPath "financePersonnel.csv"
$ouPath = "OU=$ouName,$domainComponents"

# Function to remove all child objects within the OU
function Remove-ChildObjects {
    param (
        [string]$ouPath
    )
    $childObjects = Get-ADObject -Filter * -SearchBase $ouPath
    foreach ($child in $childObjects) {
        Remove-ADObject -Identity $child.DistinguishedName -Confirm:$false -Recursive
    }
}

# Function to create the OU
function Create-OU {
    param (
        [string]$ouName,
        [string]$domainComponents
    )
    $ouPath = "OU=$ouName,$domainComponents"
    try {
        New-ADOrganizationalUnit -Name $ouName -Path $domainComponents
        Write-Output "The Organizational Unit (OU) named '$ouName' has been successfully created."
        return $ouPath
    } catch {
        Write-Output "Failed to create the Organizational Unit (OU). Error: $_"
        throw $_
    }
}

# Function to import users from CSV and add to the Finance OU
function Import-Users {
    param (
        [string]$csvFilePath,
        [string]$ouPath
    )
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
        try {
            New-ADUser -Name $displayName -GivenName $firstName -Surname $lastName -DisplayName $displayName `
                       -UserPrincipalName $userPrincipalName -SamAccountName $samAccountName `
                       -Path $ouPath -PostalCode $postalCode -OfficePhone $officePhone `
                       -MobilePhone $mobilePhone -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
                       -Enabled $true
            Write-Output "User '$displayName' has been created and added to the OU '$ouName'."
        } catch {
            Write-Output "Failed to create user '$displayName'. Error: $_"
        }
    }
}

# Function to disable protection from accidental deletion
function Disable-DeletionProtection {
    param (
        [string]$ouPath
    )
    try {
        $ou = Get-ADOrganizationalUnit -Identity $ouPath
        $ou | Set-ADObject -ProtectedFromAccidentalDeletion $false
        Write-Output "The Organizational Unit (OU) named '$ouName' is no longer protected from accidental deletion."
    } catch {
        Write-Output "Failed to disable deletion protection for the OU. Error: $_"
        throw $_
    }
}

# Check if the OU exists
Write-Output "Checking for the existence of the Organizational Unit (OU) named '$ouName'..."
$ou = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $domainComponents -ErrorAction SilentlyContinue

if ($ou) {
    Write-Output "The Organizational Unit (OU) named '$ouName' exists."
    $ouPath = $ou.DistinguishedName
    Write-Output "Distinguished Name: $ouPath"

    try {
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
        if ($_.Exception.Message -like "*Directory object not found*") {
            Write-Output "The Organizational Unit (OU) named '$ouName' was already deleted."
        } else {
            Write-Output "An unexpected error occurred while attempting to delete the Organizational Unit (OU) named '$ouName'. Error: $_"
            exit 1
        }
    }
}

Write-Output "Creating the OU and importing users."
$ouPath = Create-OU -ouName $ouName -domainComponents $domainComponents

Write-Output "Using OU Path: $ouPath"

# Import users from CSV
Import-Users -csvFilePath $csvFilePath -ouPath $ouPath

# Generate the output file for submission
try {
    Get-ADUser -Filter * -SearchBase $ouPath -Properties DisplayName,PostalCode,OfficePhone,MobilePhone | 
    Select-Object DisplayName,PostalCode,OfficePhone,MobilePhone | 
    Out-File -FilePath .\AdResults.txt
    Write-Output "Data from 'Client_A_Contacts' has been exported to 'AdResults.txt'."
} catch {
    Write-Output "Failed to export data to 'AdResults.txt': $_"
}

# End of script to prevent any further checks or actions
exit