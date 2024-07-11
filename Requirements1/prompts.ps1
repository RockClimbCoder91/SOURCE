#Geno Pickerign - 000816898

# Define the path to the Requirements1 folder
$requirementsPath = "C:\SOURCE\Requirements1"

# Function to append log files with the current date
function Append-LogFiles {
    try {
        $logFiles = Get-ChildItem -Path $requirementsPath -Filter "*.log"
        $currentDate = Get-Date -Format "yyyy-MM-dd"
        $logContent = "$currentDate`n" + ($logFiles | Out-String)
        Add-Content -Path "$requirementsPath\DailyLog.txt" -Value $logContent
    } catch [System.OutOfMemoryException] {
        Write-Host "Error: Out of memory while appending log files."
    } catch {
        Write-Host "An unexpected error occurred: $_"
    }
}

# Function to list files in tabular format
function List-Files {
    try {
        $files = Get-ChildItem -Path $requirementsPath | Sort-Object Name
        $files | Format-Table -AutoSize | Out-File "$requirementsPath\C916contents.txt"
    } catch [System.OutOfMemoryException] {
        Write-Host "Error: Out of memory while listing files."
    } catch {
        Write-Host "An unexpected error occurred: $_"
    }
}

# Function to get CPU and memory usage
function Get-CPU-Memory {
    try {
        Get-Process | Select-Object -Property Name, @{Name="CPU";Expression={[math]::Round($_.CPU, 2)}}, @{Name="Memory (MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} | Format-Table -AutoSize
    } catch [System.OutOfMemoryException] {
        Write-Host "Error: Out of memory while getting CPU and memory usage."
    } catch {
        Write-Host "An unexpected error occurred: $_"
    }
}

# Function to list running processes sorted by virtual size
function List-Processes {
    try {
        $processes = Get-Process | Sort-Object VirtualMemorySize64 | Select-Object -Property Name, Id, @{Name="VM (MB)";Expression={[math]::Round($_.VirtualMemorySize64 / 1MB, 2)}}, @{Name="PM (MB)";Expression={[math]::Round($_.PagedMemorySize64 / 1MB, 2)}}, @{Name="WS (MB)";Expression={[math]::Round($_.WorkingSet64 / 1MB, 2)}}, @{Name="CPU (s)";Expression={[math]::Round($_.CPU, 2)}}
        Write-Host "Retrieved processes:"
        $processes | Format-Table -AutoSize | Out-String
    } catch [System.OutOfMemoryException] {
        Write-Host "Error: Out of memory while listing processes."
    } catch {
        Write-Host "An unexpected error occurred: $_"
    }
}

do {
    # Prompt the user for input
    $input = Read-Host "Enter a number (1 to list .log files, 2 to list files, 3 for CPU and memory usage, 4 to list processes, 5 to exit)"
    switch ($input) {
        1 {
            Append-LogFiles
            Write-Host "Appended log files to DailyLog.txt"
        }
        2 {
            List-Files
            Write-Host "Listed files in C916contents.txt"
        }
        3 {
            Get-CPU-Memory
        }
        4 {
            $processes = List-Processes
            Write-Host $processes
        }
        5 {
            Write-Host "Exiting script."
        }
        Default {
            Write-Host "Invalid input. Please enter a number between 1 and 5."
        }
    }
} while ($input -ne 5)