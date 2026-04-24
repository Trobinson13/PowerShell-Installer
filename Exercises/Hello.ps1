$name = $args[0]

if (-not $name) {
    $name = "World"
}

Write-Host "Hello, $name!"
