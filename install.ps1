# PowerShell Installation Script for Personal Configurations

# Get the script's directory (which is the root of the repository)
$RepoDir = $PSScriptRoot

# Define the configuration mappings
$ConfigMappings = @{
    "nvim" = "$env:USERPROFILE\.config\nvim";
    "wezterm\wezterm.lua" = "$env:USERPROFILE\.wezterm.lua";
}

# Function to create a symbolic link
function Create-Symlink($Source, $Destination) {
    # Check if the destination already exists
    if (Test-Path $Destination) {
        # Create a backup
        $BackupPath = "$Destination.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Host "Backing up existing configuration to $BackupPath"
        Move-Item -Path $Destination -Destination $BackupPath -Force
    }

    # Create the symbolic link
    Write-Host "Creating symbolic link from $Source to $Destination"
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source
}

# Iterate over the mappings and create the symbolic links
foreach ($Source in $ConfigMappings.Keys) {
    $Destination = $ConfigMappings[$Source]
    $SourcePath = Join-Path -Path $RepoDir -ChildPath $Source
    Create-Symlink -Source $SourcePath -Destination $Destination
}

Write-Host "
Installation complete!"
