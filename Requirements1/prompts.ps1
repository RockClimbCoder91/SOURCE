# Geno Pickerign - 000816898

# Get the directory of the currently running script
$scriptDirectory = $PSScriptRoot

# Function to append log files with the current date
function Append-LogFiles {
    try {
        $logFiles = Get-ChildItem -Path $scriptDirectory -Filter "*.log"
        $currentDate = Get-Date -Format "yyyy-MM-dd"
        $logContent = "$currentDate`n" + ($logFiles | Out-String)
        Add-Content -Path "$scriptDirectory\DailyLog.txt" -Value $logContent
    } catch [System.OutOfMemoryException] {
        Write-Host "Error: Out of memory while appending log files."
    } catch {
        Write-Host "An unexpected error occurred: $_"
    }
}

# Function to list files in tabular format
function List-Files {
    try {
        $files = Get-ChildItem -Path $scriptDirectory | Sort-Object Name
        $files | Format-Table -AutoSize | Out-File "$scriptDirectory\C916contents.txt"
    } catch [System.OutOfMemoryException] {
        Write-Host "Error: Out of memory while listing files."
    } catch {
        Write-Host "An unexpected error occurred: $_"
    }
}

# Function to get overall system CPU and memory usage
function Get-CPU-Memory {
    try {
        $cpu = Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
        $memory = Get-CimInstance -ClassName Win32_OperatingSystem
        $totalMemory = [math]::round($memory.TotalVisibleMemorySize / 1MB, 2)
        $freeMemory = [math]::round($memory.FreePhysicalMemory / 1MB, 2)
        $usedMemory = $totalMemory - $freeMemory

        Write-Host ("CPU Usage: {0}%" -f $cpu)
        Write-Host ("Total Memory: {0} MB" -f $totalMemory)
        Write-Host ("Used Memory: {0} MB" -f $usedMemory)
        Write-Host ("Free Memory: {0} MB" -f $freeMemory)
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
