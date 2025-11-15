function Write-ColorOutput {
    <#
    .SYNOPSIS
    Writes colored output with emoji support that's compatible with both PS 5.1 and PS 7+.

    .DESCRIPTION
    This function writes colored output and automatically uses emojis in PowerShell 7+ 
    while falling back to simple text symbols in PowerShell 5.1 to avoid encoding issues.

    .PARAMETER Message
    The message to display.

    .PARAMETER ForegroundColor
    The color to use for the text.

    .PARAMETER NoNewline
    If specified, does not add a newline at the end.

    .PARAMETER Symbol
    The symbol type to prepend: 'Success', 'Warning', 'Clean', 'Remove', 'Info', 'Error', 'Pending', 'Clap'
    #>

    param(
        [string]$Message,
        [string]$ForegroundColor = 'White',
        [switch]$NoNewline,
        [ValidateSet('Success', 'Warning', 'Clean', 'Remove', 'Info', 'Error', 'Pending', 'Clap', 'None')]
        [string]$Symbol = 'None'
    )

    # Determine if we can use emojis (PS 7+)
    $useEmoji = $PSVersionTable.PSVersion.Major -ge 7

    # Map symbols to emoji and fallback characters
    # Using Unicode code points to avoid PS 5.1 parsing issues with emoji literals
    $symbols = @{
        'Success' = if ($useEmoji) { [char]::ConvertFromUtf32(0x2705) } else { '[*]' }
        'Warning' = if ($useEmoji) { [char]::ConvertFromUtf32(0x26A0) + [char]::ConvertFromUtf32(0xFE0F) + ' ' } else { '[!]' }
        'Clean'   = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F9F9) } else { '[-]' }
        'Remove'  = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F5D1) + [char]::ConvertFromUtf32(0xFE0F) + ' ' } else { '[x]' }
        'Info'    = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F4A1) } else { '[*]' }
        'Error'   = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F53A) } else { '[X]' }
        'Pending' = if ($useEmoji) { [char]::ConvertFromUtf32(0x231B) } else { '[~]' }
        'Clap'    = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F44F) } else { '[+]' }
        'None'    = ''
    }

    $prefix = if ($Symbol -ne 'None') { "$($symbols[$Symbol]) " } else { '' }
    $fullMessage = "$prefix$Message"

    if ($NoNewline) {
        Write-Host $fullMessage -ForegroundColor $ForegroundColor -NoNewline
    }
    else {
        Write-Host $fullMessage -ForegroundColor $ForegroundColor
    }
}
