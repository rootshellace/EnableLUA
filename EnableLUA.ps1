# Define Log File Name

$LUALogFileName = "LUA_Log_File.txt"
$LUALogPath = -join($Env:USERPROFILE, "\", $LUALogFileName)

# Test If The Log File Exists

$LUALogExists = Test-Path -LiteralPath $LUALogPath -PathType Leaf

if (-not $LUALogExists)
{
    try 
    {
        Write-Output -InputObject "[-] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] File $LUALogPath doesn't exist!"
        Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] Creating file $LUALogPath..."
        New-Item -Path $LUALogPath -ItemType File
        Write-Output -InputObject "`n"
        Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] File $LUALogPath has been created!"
        Write-Output -InputObject "`n"
    }
    catch 
    {
        Write-Output -InputObject "[x] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] An error occured when trying to create the log file: $($_.Exception.Message)"
        Write-Output -InputObject "[x] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] The script will exit!"
        Exit 2
    }
}
else 
{
    Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] File $LUALogPath has been found!"
    Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] The script will continue!"
}

# Interrogate The Registry

$RegistryPathLUA = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\"
$PropertyNameLUA = "EnableLUA"

try 
{
    Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] Retrieving registry value for EnableLUA..." | Tee-Object -FilePath $LUALogPath -Append
    $RegValueLUA = (Get-ItemProperty -Path $RegistryPathLUA -Name $PropertyNameLUA -ErrorAction Stop).$PropertyNameLUA
    Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] $PropertyNameLUA registry value is $RegValueLUA" | Tee-Object -FilePath $LUALogPath -Append
}
catch 
{
    Write-Output -InputObject "[x] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] An error occured when trying to get the registry value!" | Tee-Object -FilePath $LUALogPath -Append
    Write-Output -InputObject "[x] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] Error: $($_.Exception.Message)" | Tee-Object -FilePath $LUALogPath -Append
    Write-Output -InputObject "[x] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] The script will exit!" | Tee-Object -FilePath $LUALogPath -Append
    Exit 3
}

# Verify The Status And Log It

if ($RegValueLUA -eq 1)
{
    Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] LUA is enabled, no action needed!" | Tee-Object -FilePath $LUALogPath -Append
}
else 
{
    Write-Output -InputObject "[-] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] LUA is disabled!" | Tee-Object -FilePath $LUALogPath -Append

    try 
    {
        Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] Trying to enable LUA..." | Tee-Object -FilePath $LUALogPath -Append
        Set-ItemProperty -Path $RegistryPathLUA -Name $PropertyNameLUA -Value 1 -ErrorAction Stop
        $NewValLUA = (Get-ItemProperty -Path $RegistryPathLUA -Name $PropertyNameLUA -ErrorAction Stop).$PropertyNameLUA
        if ($NewValLUA -eq 1)
        {
            Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] LUA Successfully Enabled!" | Tee-Object -FilePath $LUALogPath -Append
        }
        Write-Output -InputObject "[+] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] Restarting PC in 60 seconds..." | Tee-Object -FilePath $LUALogPath -Append
        Start-Sleep -Seconds 60
        Restart-Computer
    }
    catch 
    {
        Write-Output -InputObject "[x] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] An error occured when trying to change the registry value!" | Tee-Object -FilePath $LUALogPath -Append
        Write-Output -InputObject "[x] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] Error: $($_.Exception.Message)" | Tee-Object -FilePath $LUALogPath -Append
        Write-Output -InputObject "[x] [$(Get-Date -Format "yyyy-MM-dd:HH-mm-ss")] [$([System.Environment]::UserName)] The script will exit!" | Tee-Object -FilePath $LUALogPath -Append
        Exit 4
    }
}
