function Get-FileInfo {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path
    )
    
    $file = Get-Item -path $Path

    return @{
        Name            = $file.Name
        SizeBytes       = $file.Length
        LastModified    = $file.LastWriteTime
    }
}