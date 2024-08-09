# Define constant variable
$taskName = "CloseLOLAsAdmin"
$batName = "close-lol.bat"
$shortcutName = "CleanseLOL.lnk"
$hotKey = "F11"

# Get the script's directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$batchFilePath = Join-Path -Path $scriptDir -ChildPath $batName

$desktopDir = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path -Path $desktopDir -ChildPath $shortcutName


# Get the current user's ID
$currentUserId = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Check if the task already exists
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($taskExists) {
    Write-Output "Task already exists, so skip the rest steps."
    exit
} else {
    # Create the task in Task Scheduler
    $action = New-ScheduledTaskAction -Execute "$batchFilePath"
    $principal = New-ScheduledTaskPrincipal -UserId $currentUserId -LogonType ServiceAccount -RunLevel Highest
    $task = New-ScheduledTask -Action $action -Principal $principal -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries)
    Register-ScheduledTask -TaskName $taskName -InputObject $task -Force
    Write-Output "Task created successfully."
}

# Create a shortcut to run the task
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "schtasks.exe"
$shortcut.Arguments = "/run /tn $taskName"
$shortcut.Hotkey = $hotKey
$shortcut.Save()

Write-Output "Shortcut created successfully."