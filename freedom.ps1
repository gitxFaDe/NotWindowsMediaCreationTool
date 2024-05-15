# Define variables
$isoUrl = "https://mirrors.edge.kernel.org/archlinux/iso/latest/archlinux-x86_64.iso"
$downloadPath = "$env:USERPROFILE\Downloads\archlinux.iso"
$usbDriveLetter = "E:"  # Change this to your USB drive letter

# Function to download the latest Arch Linux ISO
function Download-ArchLinuxISO {
    Write-Output "Downloading the latest Arch Linux ISO from $isoUrl..."
    Invoke-WebRequest -Uri $isoUrl -OutFile $downloadPath
    Write-Output "Downloaded ISO to $downloadPath"
}

# Function to prepare the USB drive
function Prepare-USBDrive {
    param (
        [string]$driveLetter
    )
    Write-Output "Preparing USB drive $driveLetter..."
    $diskPartScript = @"
select disk $driveLetter
clean
create partition primary
active
format fs=fat32 quick
assign letter=$driveLetter
exit
"@
    $diskPartScript | Out-File -FilePath "$env:TEMP\diskpart_script.txt" -Encoding ASCII
    Start-Process -FilePath "diskpart.exe" -ArgumentList "/s `"$env:TEMP\diskpart_script.txt`"" -Wait -NoNewWindow
    Write-Output "USB drive $driveLetter prepared successfully."
}

# Function to extract ISO to USB drive
function ExtractISOToUSB {
    param (
        [string]$isoPath,
        [string]$driveLetter
    )
    Write-Output "Extracting ISO to USB drive $driveLetter..."
    $sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
    if (-Not (Test-Path $sevenZipPath)) {
        Write-Error "7-Zip is not installed. Please install 7-Zip and try again."
        exit
    }
    & "$sevenZipPath" x $isoPath -o$driveLetter
    Write-Output "ISO extracted to USB drive $driveLetter successfully."
}

# Main script execution
Download-ArchLinuxISO
Prepare-USBDrive -driveLetter $usbDriveLetter
ExtractISOToUSB -isoPath $downloadPath -driveLetter $usbDriveLetter

Write-Output "Bootable Arch Linux USB drive created successfully."
