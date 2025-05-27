function Test-IsAdmin {
    <#
    .SYNOPSIS
    Checks if the current PowerShell session is running with administrator privileges.

    .DESCRIPTION
    This function determines if the current PowerShell session has administrator privileges on Windows systems.
    For non-Windows systems, it assumes sufficient privileges are available.

    .OUTPUTS
    [bool] Returns $true if running as administrator, $false otherwise.
    #>

    if ($PSVersionTable.PSVersion.Major -ge 6 -and $IsWindows -eq $false) {
        return $true  # On non-Windows systems, assume we have sufficient privileges
    }

    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        Write-Warning "Could not determine if running as administrator. Proceeding anyway."
        return $true
    }
}
