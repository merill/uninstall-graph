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
        [switch]$NoNewline
    )

    # Determine if we can use emojis (PS 7+)
    $useEmoji = $PSVersionTable.PSVersion.Major -ge 7

    # Map ASCII placeholders to emoji (PS7+) and ASCII symbols (PS5.1)
    # Using Unicode code points to avoid PS 5.1 parsing issues with emoji literals
    $replacements = @{
        '[*]' = if ($useEmoji) { [char]::ConvertFromUtf32(0x2705) } else { '[*]' }  # Success/checkmark
        '[!]' = if ($useEmoji) { [char]::ConvertFromUtf32(0x26A0) + [char]::ConvertFromUtf32(0xFE0F) + ' ' } else { '[!]' }  # Warning
        '[-]' = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F9F9) } else { '[-]' }  # Clean/broom
        '[x]' = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F5D1) + [char]::ConvertFromUtf32(0xFE0F) + ' ' } else { '[x]' }  # Remove/trash
        '[>]' = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F4A1) } else { '[>]' }  # Info/lightbulb
        '[?]' = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F53A) } else { '[?]' }  # Error/red triangle
        '[~]' = if ($useEmoji) { [char]::ConvertFromUtf32(0x231B) } else { '[~]' }  # Pending/hourglass
        '[+]' = if ($useEmoji) { [char]::ConvertFromUtf32(0x1F44F) } else { '[+]' }  # Done/clapping
    }

    # Replace all ASCII placeholders in the message
    $fullMessage = $Message
    foreach ($placeholder in $replacements.Keys) {
        $fullMessage = $fullMessage.Replace($placeholder, $replacements[$placeholder])
    }

    if ($NoNewline) {
        Write-Host $fullMessage -ForegroundColor $ForegroundColor -NoNewline
    }
    else {
        Write-Host $fullMessage -ForegroundColor $ForegroundColor
    }
}
