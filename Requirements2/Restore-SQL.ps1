#Geno Pickerign - 000816898

# Define the database name
$databaseName = "ClientDB"

# Define the SQL Server instance
$serverInstance = "SRV19-PRIMARY\SQLEXPRESS" # Change this to your SQL Server instance name

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
} catch {
    Write-Host "An error occurred: $_"
}

