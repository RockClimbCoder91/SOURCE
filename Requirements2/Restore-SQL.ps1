#Geno Pickerign - 000816898

# Define the database name
$databaseName = "ClientDB"

# Define the SQL Server instance
$serverInstance = "SRV19-PRIMARY\SQLEXPRESS" # Change this to your SQL Server instance name

# Get the current script directory and define the CSV file path
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$csvFilePath = Join-Path -Path $scriptDirectory -ChildPath "NewClientData.csv"

try {
    # Check if the database exists
    $checkDbQuery = @"
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'$databaseName')
BEGIN
    SELECT 1 AS DatabaseExists
END
ELSE
BEGIN
    SELECT 0 AS DatabaseExists
END
"@

    # Execute the query to check if the database exists
    $checkDbResult = Invoke-Sqlcmd -ServerInstance $serverInstance -Query $checkDbQuery -ErrorAction Stop

    # Check the result and delete the database if it exists
    if ($checkDbResult.DatabaseExists -eq 1) {
        Write-Host "The database '$databaseName' exists."

        # Delete the database
        $dropDbQuery = "DROP DATABASE [$databaseName];"
        Invoke-Sqlcmd -ServerInstance $serverInstance -Query $dropDbQuery -ErrorAction Stop
        Write-Host "The database '$databaseName' was deleted."
    } else {
        Write-Host "The database '$databaseName' does not exist."
    }

    # Create the database
    $createDbQuery = "CREATE DATABASE [$databaseName];"
    Invoke-Sqlcmd -ServerInstance $serverInstance -Query $createDbQuery -ErrorAction Stop
    Write-Host "The database '$databaseName' was created."

    # Create the table in the new database
    $createTableQuery = @"
USE [$databaseName];
CREATE TABLE Client_A_Contacts (
    ContactID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    City NVARCHAR(50),
    County NVARCHAR(50),
    Zip NVARCHAR(10),
    OfficePhone NVARCHAR(15),
    MobilePhone NVARCHAR(15)
);
"@
    Invoke-Sqlcmd -ServerInstance $serverInstance -Query $createTableQuery -ErrorAction Stop
    Write-Host "The table 'Client_A_Contacts' was created in the database '$databaseName'."

    # Read the CSV file and insert data into the table
    $csvData = Import-Csv -Path $csvFilePath

    foreach ($row in $csvData) {
        # Ensure that single quotes in data are escaped for SQL
        $firstName = $row.first_name -replace "'", "''"
        $lastName = $row.last_name -replace "'", "''"
        $city = $row.city -replace "'", "''"
        $county = $row.county -replace "'", "''"
        $zip = $row.zip
        $officePhone = $row.officePhone
        $mobilePhone = $row.mobilePhone

        $insertQuery = @"
USE [$databaseName];
INSERT INTO Client_A_Contacts (FirstName, LastName, City, County, Zip, OfficePhone, MobilePhone)
VALUES ('$firstName', '$lastName', '$city', '$county', '$zip', '$officePhone', '$mobilePhone');
"@
        try {
            Invoke-Sqlcmd -ServerInstance $serverInstance -Query $insertQuery -ErrorAction Stop
            Write-Host "Inserted: $firstName $lastName"
        } catch {
            Write-Host "Failed to insert row: $_"
        }
    }

    Write-Host "Data from '$csvFilePath' has been inserted into the table 'Client_A_Contacts'."

    # Generate the output file SqlResults.txt for submission
    $outputFilePath = Join-Path -Path $scriptDirectory -ChildPath "SqlResults.txt"
    $selectQuery = "USE [$databaseName]; SELECT * FROM Client_A_Contacts;"
    Invoke-Sqlcmd -ServerInstance $serverInstance -Query $selectQuery -ErrorAction Stop | Out-File -FilePath $outputFilePath

    Write-Host "Data from 'Client_A_Contacts' has been exported to 'SqlResults.txt'."

} catch {
    Write-Host "An error occurred: $_"
}