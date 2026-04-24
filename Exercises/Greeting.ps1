function Get-Greeting {
    param(
        [string]$Greeting = "Hello",
        [string]$Name = "World",
        [switch]$Loud
    )

    $message = "$Greeting, $Name!"

    if ($Loud) {
        $message = $message.ToUpper()
    }

    return $message
}
