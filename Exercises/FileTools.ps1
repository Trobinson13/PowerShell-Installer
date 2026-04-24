function Get-FileInfo {
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path
    )

    $file = Get-Item -Path $Path

    return @{
        Name         = $file.Name
        SizeBytes    = $file.Length
        LastModified = $file.LastWriteTime
    }
}
