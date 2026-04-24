function Get-Sum {
    param(
        [Parameter(Mandatory)]
        [int]$A,

        [Parameter(Mandatory)]
        [ValidateRange(1, 100)]
        [int]$B
    )

    return $A + $B
    
}