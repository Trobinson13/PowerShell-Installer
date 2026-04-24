# PowerShell Installer Curriculum

A hands-on learning path from zero PowerShell to a production-grade `Install-DeveloperSoftware` function with Pester tests, classes, and error handling.

Each module builds on the last. Write the code, run it, break it, fix it.

---

## Module 1: Scripts, Functions, and Parameters

**Goal:** By the end of this module, you should be able to create a script file, run it, turn repeated logic into a function, pass named parameters, validate input, and control what your function returns.

**Files you will create:**
- `Hello.ps1`
- `Greeting.ps1`
- `MathHelper.ps1`
- `FileTools.ps1`

### 1.1 - Your First `.ps1` File

A `.ps1` file is a PowerShell script. It is just a text file containing PowerShell commands.

Create a file called `Hello.ps1`:

```powershell
# Hello.ps1
Write-Host "Hello from a script file!"
```

Run it from the folder where the file lives:

```powershell
.\Hello.ps1
```

Expected output:

```text
Hello from a script file!
```

> **Note:** If you get an execution policy error, run this once, then try the script again:
>
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```

Now make the script accept a name from the command line:

```powershell
# Hello.ps1
$name = $args[0]

if (-not $name) {
    $name = "World"
}

Write-Host "Hello, $name!"
```

Run both versions:

```powershell
.\Hello.ps1
.\Hello.ps1 Tre
```

Expected output:

```text
Hello, World!
Hello, Tre!
```

**Checkpoint:** `$args` is the automatic array PowerShell fills with unnamed arguments passed to a script. `$args[0]` means "the first argument."

**Exercise:** Add a second argument for the greeting word. For example, `.\Hello.ps1 Tre Hi` should print `Hi, Tre!`. If no greeting is provided, default to `Hello`.

---

### 1.2 - Writing Functions

Scripts are good for running commands. Functions are better when you want reusable logic.

Create `Greeting.ps1`:

```powershell
# Greeting.ps1
function Get-Greeting {
    param(
        [string]$Name = "World"
    )

    return "Hello, $Name!"
}
```

Load the function into your current terminal session by dot-sourcing the file:

```powershell
. .\Greeting.ps1
```

The first dot means "load this into the current session." The second dot is part of the relative path `.\Greeting.ps1`. The space between them matters.

Now call the function:

```powershell
Get-Greeting
Get-Greeting -Name "Tre"
```

Expected output:

```text
Hello, World!
Hello, Tre!
```

**Key concepts:**
- `function Get-Greeting { ... }` defines a reusable command.
- `param()` declares named parameters.
- `[string]$Name = "World"` means the parameter should be text and has a default value.
- `return` sends a value back to the caller.
- Dot-sourcing (`. .\File.ps1`) loads functions into the current scope.

Add a `-Loud` switch parameter:

```powershell
function Get-Greeting {
    param(
        [string]$Name = "World",
        [switch]$Loud
    )

    $message = "Hello, $Name!"

    if ($Loud) {
        $message = $message.ToUpper()
    }

    return $message
}
```

Try it:

```powershell
. .\Greeting.ps1
Get-Greeting -Name "Tre"
Get-Greeting -Name "Tre" -Loud
```

Expected output:

```text
Hello, Tre!
HELLO, TRE!
```

**Checkpoint:** A `[switch]` parameter works like an on/off flag. If you include `-Loud`, `$Loud` is true. If you leave it off, `$Loud` is false.

**Exercise:** Add a `[string]$Greeting = "Hello"` parameter so this works:

```powershell
Get-Greeting -Name "Tre" -Greeting "Welcome"
```

Expected output:

```text
Welcome, Tre!
```

---

### 1.3 - Mandatory Parameters and Validation

PowerShell can enforce parameter rules before the function body runs.

Create `MathHelper.ps1`:

```powershell
# MathHelper.ps1
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
```

Load and call it:

```powershell
. .\MathHelper.ps1
Get-Sum -A 3 -B 7
```

Expected output:

```text
10
```

Now test the guardrails:

```powershell
Get-Sum
Get-Sum -A 3 -B 200
```

What should happen:
- `Get-Sum` prompts you for the mandatory values.
- `-B 200` fails because `B` must be from `1` through `100`.

**Key concepts:**
- `[Parameter(Mandatory)]` requires the caller to provide a value.
- `[ValidateRange(1, 100)]` rejects numbers outside the allowed range.
- Validation keeps bad input out of your function body.

Create `FileTools.ps1`:

```powershell
# FileTools.ps1
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
```

Try it against one of your existing files:

```powershell
. .\FileTools.ps1
Get-FileInfo -Path .\Hello.ps1
```

**Exercise:** Add a `[ValidateScript()]` rule to `Get-Greeting` that rejects blank names. Hint: `-not [string]::IsNullOrWhiteSpace($_)`.

---

### 1.4 - Output, Return Values, and the Pipeline

PowerShell functions emit all uncaptured output to the pipeline, not just what you `return`. This is one of the first surprising things worth learning.

Try this example:

```powershell
function Get-Data {
    Write-Host "Starting..."       # console only, not captured in the result
    "some debug text"              # pipeline output
    return @{ Value = 42 }         # also pipeline output
}

$result = Get-Data
$result
$result.GetType().FullName
```

`$result` contains both `"some debug text"` and the hashtable. Because there are two pipeline outputs, PowerShell stores them as an array.

**Rules of thumb:**
- Use `Write-Host` for simple screen-only messages.
- Use `Write-Verbose` for optional diagnostic messages.
- Use `Write-Output` or bare expressions for intentional pipeline output.
- Use `return` for clarity, but remember it does not erase earlier output.

Create a clean function:

```powershell
function Get-Square {
    param(
        [int]$Number
    )

    return $Number * $Number
}
```

Verify that it returns only one value:

```powershell
$result = Get-Square -Number 5
$result
$result.GetType().FullName
```

Expected output:

```text
25
System.Int32
```

**Exercise:** Add `Get-Square` to `MathHelper.ps1`, dot-source the file again, and confirm both `Get-Sum` and `Get-Square` are available in your session.

**Module 1 review:**
- Run a script with `.\ScriptName.ps1`.
- Use `$args` for quick unnamed script arguments.
- Prefer `param()` for real functions.
- Dot-source files when you want their functions available in your current session.
- Use validation attributes to reject bad input early.
- Be intentional about what your functions write to the pipeline.

---

## Module 2: Pester Testing Fundamentals

### 2.1 — Installing and Running Pester

Pester is PowerShell's testing framework (think NUnit/xUnit but for scripts). Install it:

```powershell
Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck
Import-Module Pester
```

Convention: test files are named `*.Tests.ps1` and live alongside the code they test.

---

### 2.2 — Your First Test

Given `Greeting.ps1` from Module 1, create `Greeting.Tests.ps1`:

```powershell
# Greeting.Tests.ps1

BeforeAll {
    . $PSScriptRoot/Greeting.ps1    # dot-source the code under test
}

Describe "Get-Greeting" {
    It "returns a greeting with the given name" {
        $result = Get-Greeting -Name "Tre"
        $result | Should -Be "Hello, Tre!"
    }

    It "defaults to 'World' when no name is given" {
        $result = Get-Greeting
        $result | Should -Be "Hello, World!"
    }

    It "uppercases output when -Loud is set" {
        $result = Get-Greeting -Name "Tre" -Loud
        $result | Should -Be "HELLO, TRE!"
    }
}
```

Run it:

```powershell
Invoke-Pester ./Greeting.Tests.ps1 -Output Detailed
```

**Key concepts:**
- `BeforeAll` runs once before the `Describe` block — use it to load your code.
- `Describe` groups related tests. `It` is a single test case.
- `Should -Be` is an exact-match assertion. Other useful ones: `-BeTrue`, `-BeLike`, `-Contain`, `-Throw`.

---

### 2.3 — Testing for Errors

You can assert that a function throws:

```powershell
Describe "Get-Sum" {
    BeforeAll {
        . $PSScriptRoot/MathHelper.ps1
    }

    It "throws when B is out of range" {
        { Get-Sum -A 1 -B 200 } | Should -Throw
    }

    It "returns the correct sum" {
        Get-Sum -A 3 -B 7 | Should -Be 10
    }
}
```

**Exercise:** Write tests for the `Get-FileInfo` function from 1.3. Test both the happy path (valid file) and the sad path (nonexistent path should throw). Use `BeforeAll` to create a temp file with `New-Item` and `AfterAll` to clean it up.

---

### 2.4 — Mocking with Pester

Mocking lets you replace real commands with fakes so you can test logic in isolation without side effects:

```powershell
Describe "Install simulation" {
    It "calls winget with the correct arguments" {
        Mock winget { return "Successfully installed" }

        $result = winget install --id Git.Git -e --source winget
        $result | Should -Be "Successfully installed"

        Should -Invoke winget -Times 1 -Exactly
    }
}
```

This is critical for Module 5+ where you'll test install logic without actually installing software.

**Exercise:** Write a function `Test-CommandExists` that checks if a command is available (`Get-Command`). Then write a test that mocks `Get-Command` to simulate both found and not-found scenarios.

---

## Module 3: PowerShell Classes

### 3.1 — Defining a Class

PowerShell 5.1+ supports classes. They're defined with the `class` keyword:

```powershell
# Models.ps1
class SoftwarePackage {
    [string]$Name
    [string]$WingetId
    [string]$VerifyCommand    # command to check if already installed

    SoftwarePackage([string]$name, [string]$wingetId, [string]$verifyCommand) {
        $this.Name = $name
        $this.WingetId = $wingetId
        $this.VerifyCommand = $verifyCommand
    }

    [string] ToString() {
        return "$($this.Name) ($($this.WingetId))"
    }
}
```

Usage:

```powershell
. .\Models.ps1
$git = [SoftwarePackage]::new("Git", "Git.Git", "git")
Write-Host $git    # prints: Git (Git.Git)
```

**Key concepts:**
- Constructors match the class name.
- `$this` references the current instance.
- Methods use `[returnType] MethodName() { }` syntax.
- Instantiate with `[ClassName]::new()` (not `New-Object` — that's the older pattern).

**Exercise:** Add a `[bool] IsInstalled()` method to `SoftwarePackage` that runs `Get-Command $this.VerifyCommand -ErrorAction SilentlyContinue` and returns `$true`/`$false`.

---

### 3.2 — Enums

Enums are great for representing fixed states:

```powershell
enum InstallStatus {
    Pending
    Skipped       # already installed
    Installing
    Succeeded
    Failed
}
```

**Exercise:** Add an `[InstallStatus]$Status` property to `SoftwarePackage`, defaulting to `Pending` in the constructor.

---

### 3.3 — A Tracker Class

Now build a class that aggregates results:

```powershell
class InstallTracker {
    [System.Collections.Generic.List[SoftwarePackage]]$Packages
    [datetime]$StartTime

    InstallTracker() {
        $this.Packages = [System.Collections.Generic.List[SoftwarePackage]]::new()
        $this.StartTime = Get-Date
    }

    [void] Add([SoftwarePackage]$package) {
        $this.Packages.Add($package)
    }

    [SoftwarePackage[]] GetFailed() {
        return $this.Packages | Where-Object { $_.Status -eq [InstallStatus]::Failed }
    }

    [SoftwarePackage[]] GetSucceeded() {
        return $this.Packages | Where-Object { $_.Status -eq [InstallStatus]::Succeeded }
    }

    [string] GetSummary() {
        $total    = $this.Packages.Count
        $ok       = ($this.GetSucceeded()).Count
        $fail     = ($this.GetFailed()).Count
        $skipped  = ($this.Packages | Where-Object { $_.Status -eq [InstallStatus]::Skipped }).Count
        $elapsed  = (Get-Date) - $this.StartTime

        return @"
===== Install Summary =====
Total:     $total
Succeeded: $ok
Failed:    $fail
Skipped:   $skipped
Elapsed:   $($elapsed.ToString("mm\:ss"))
===========================
"@
    }
}
```

**Exercise:** Add a `[void] PrintFailureReport()` method that writes each failed package's name and any stored error message to the console with `Write-Warning`.

---

### 3.4 — Testing Classes

Classes load differently in Pester. You must dot-source the file containing the class definition in `BeforeAll`:

```powershell
# Models.Tests.ps1

BeforeAll {
    . $PSScriptRoot/Models.ps1
}

Describe "SoftwarePackage" {
    It "initializes with Pending status" {
        $pkg = [SoftwarePackage]::new("Git", "Git.Git", "git")
        $pkg.Status | Should -Be ([InstallStatus]::Pending)
    }

    It "detects installed software" {
        Mock Get-Command { return $true }
        $pkg = [SoftwarePackage]::new("Git", "Git.Git", "git")
        $pkg.IsInstalled() | Should -BeTrue
    }
}

Describe "InstallTracker" {
    It "tracks failed packages" {
        $tracker = [InstallTracker]::new()
        $pkg = [SoftwarePackage]::new("Bad Tool", "Bad.Tool", "badtool")
        $pkg.Status = [InstallStatus]::Failed
        $tracker.Add($pkg)

        $failures = $tracker.GetFailed()
        $failures.Count | Should -Be 1
        $failures[0].Name | Should -Be "Bad Tool"
    }
}
```

**Exercise:** Write a test that adds 3 packages (1 succeeded, 1 failed, 1 skipped) and asserts `GetSummary()` contains the correct counts.

---

## Module 4: Error Handling and Logging

### 4.1 — Try/Catch and `-ErrorAction Stop`

By default, many PowerShell cmdlet errors are **non-terminating** — they write to the error stream but don't trigger `catch`. To make them catchable, use `-ErrorAction Stop`:

```powershell
function Install-WithWinget {
    param(
        [Parameter(Mandatory)]
        [SoftwarePackage]$Package
    )

    try {
        $Package.Status = [InstallStatus]::Installing
        Write-Host "  Installing $($Package.Name)..." -ForegroundColor Cyan

        $output = winget install --id $Package.WingetId -e --source winget `
                    --accept-package-agreements --accept-source-agreements 2>&1

        if ($LASTEXITCODE -ne 0) {
            throw "winget exited with code $LASTEXITCODE. Output: $output"
        }

        $Package.Status = [InstallStatus]::Succeeded
        Write-Host "  ✓ $($Package.Name) installed." -ForegroundColor Green
    }
    catch {
        $Package.Status = [InstallStatus]::Failed
        $Package | Add-Member -NotePropertyName "ErrorDetail" -NotePropertyValue $_.Exception.Message -Force
        Write-Warning "  ✗ $($Package.Name) failed: $($_.Exception.Message)"
    }
}
```

**Key concepts:**
- `2>&1` redirects stderr into the output stream so you can capture it.
- `$LASTEXITCODE` holds the exit code of the last native executable.
- `throw` inside `try` triggers the `catch` block.
- `Add-Member` dynamically attaches an error detail property to the object for later reporting.

**Exercise:** Write a wrapper function `Invoke-SafeCommand` that takes a `[scriptblock]$Action` and a `[string]$Label`, runs the action in a try/catch, and returns a hashtable `@{ Success = $true/$false; Error = $null/message }`. Write Pester tests for both outcomes.

---

### 4.2 — Logging to a File

```powershell
function Write-InstallLog {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO",

        [string]$LogPath = "$PSScriptRoot\install.log"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $entry

    # also echo to console with color
    switch ($Level) {
        "WARN"  { Write-Warning $Message }
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        default { Write-Verbose $Message }
    }
}
```

**Exercise:** Modify `Install-WithWinget` to call `Write-InstallLog` on both success and failure. Write a Pester test that mocks `Add-Content` and asserts the log entry format.

---

## Module 5: Building `Install-DeveloperSoftware`

### 5.1 — The Package Manifest

Define the software list as structured data, not scattered conditionals:

```powershell
# PackageManifest.ps1
. $PSScriptRoot/Models.ps1

function Get-DeveloperPackages {
    return @(
        [SoftwarePackage]::new("Git",             "Git.Git",                        "git")
        [SoftwarePackage]::new("NVM for Windows", "CoreyButler.NVMforWindows",      "nvm")
        [SoftwarePackage]::new("Notepad++",       "Notepad++.Notepad++",            "notepad++")
        [SoftwarePackage]::new("VS Code",         "Microsoft.VisualStudioCode",     "code")
        [SoftwarePackage]::new("Docker Desktop",  "Docker.DockerDesktop",           "docker")
        [SoftwarePackage]::new("GitHub CLI",      "GitHub.cli",                     "gh")
    )
}
```

This is easy to extend — just add a line. Tests can assert against the list without triggering installs.

---

### 5.2 — The Main Function

```powershell
# Install-DeveloperSoftware.ps1
. $PSScriptRoot/Models.ps1
. $PSScriptRoot/PackageManifest.ps1

function Install-DeveloperSoftware {
    [CmdletBinding()]
    param(
        [string]$LogPath = "$PSScriptRoot\install.log",
        [switch]$WhatIf                           # dry-run mode
    )

    Write-Host "`n=== Developer Software Installer ===" -ForegroundColor Yellow
    Write-InstallLog -Message "Install session started" -LogPath $LogPath

    $tracker = [InstallTracker]::new()
    $packages = Get-DeveloperPackages

    foreach ($pkg in $packages) {
        $tracker.Add($pkg)

        # skip check
        if ($pkg.IsInstalled()) {
            $pkg.Status = [InstallStatus]::Skipped
            Write-Host "  ~ $($pkg.Name) already installed, skipping." -ForegroundColor DarkGray
            Write-InstallLog -Message "$($pkg.Name) skipped (already installed)" -LogPath $LogPath
            continue
        }

        if ($WhatIf) {
            Write-Host "  [WhatIf] Would install $($pkg.Name) ($($pkg.WingetId))"
            $pkg.Status = [InstallStatus]::Skipped
            continue
        }

        Install-WithWinget -Package $pkg
        Write-InstallLog -Message "$($pkg.Name): $($pkg.Status)" -Level $(
            if ($pkg.Status -eq [InstallStatus]::Failed) { "ERROR" } else { "INFO" }
        ) -LogPath $LogPath
    }

    # summary
    $summary = $tracker.GetSummary()
    Write-Host $summary
    Write-InstallLog -Message $summary -LogPath $LogPath

    # failure report
    $failures = $tracker.GetFailed()
    if ($failures.Count -gt 0) {
        Write-Host "`nFailed packages:" -ForegroundColor Red
        foreach ($f in $failures) {
            Write-Warning "  - $($f.Name): $($f.ErrorDetail)"
        }
        Write-InstallLog -Message "Failures: $(($failures | ForEach-Object { $_.Name }) -join ', ')" `
                         -Level "ERROR" -LogPath $LogPath
    }
}
```

**Key behaviors:**
- Continues on error (the try/catch in `Install-WithWinget` handles it per-package).
- Skips already-installed software.
- Logs everything.
- Prints a summary with failure details at the end.
- Supports `-WhatIf` for safe dry runs.

---

### 5.3 — Testing the Installer

This is where mocking really pays off — you never want tests to actually install software:

```powershell
# Install-DeveloperSoftware.Tests.ps1

BeforeAll {
    . $PSScriptRoot/Models.ps1
    . $PSScriptRoot/PackageManifest.ps1
    . $PSScriptRoot/Install-DeveloperSoftware.ps1

    Mock winget { return "mock install complete" }
    Mock Add-Content { }                             # suppress log file writes
}

Describe "Install-DeveloperSoftware" {
    Context "when all packages install successfully" {
        BeforeAll {
            Mock Get-Command { return $null }        # nothing pre-installed
            $global:LASTEXITCODE = 0                 # winget "succeeds"
        }

        It "marks all packages as Succeeded" {
            # You'd need to capture the tracker — see refactoring note below
            { Install-DeveloperSoftware } | Should -Not -Throw
        }

        It "calls winget for every package" {
            $expected = (Get-DeveloperPackages).Count
            Should -Invoke winget -Times $expected
        }
    }

    Context "when a package is already installed" {
        BeforeAll {
            # simulate Git being found
            Mock Get-Command {
                if ($args[0] -eq "git") { return @{ Name = "git" } }
                return $null
            } -ParameterFilter { $true }
        }

        It "skips the installed package and installs the rest" {
            { Install-DeveloperSoftware } | Should -Not -Throw
            $total = (Get-DeveloperPackages).Count
            Should -Invoke winget -Times ($total - 1)
        }
    }

    Context "when a package fails to install" {
        BeforeAll {
            Mock Get-Command { return $null }
            Mock winget { throw "network error" }
        }

        It "does not throw — continues on error" {
            { Install-DeveloperSoftware } | Should -Not -Throw
        }
    }
}
```

**Refactoring note:** To make the tracker's state inspectable in tests, have `Install-DeveloperSoftware` return the `$tracker` object (`return $tracker` at the end). Then tests can assert on `$result.GetFailed().Count`, `$result.GetSucceeded().Count`, etc.

---

## Module 6: Putting It All Together

### 6.1 — Final Project Structure

```
DevInstaller/
├── Models.ps1                           # SoftwarePackage, InstallStatus, InstallTracker
├── PackageManifest.ps1                  # Get-DeveloperPackages
├── Logging.ps1                          # Write-InstallLog
├── Install-WithWinget.ps1               # single-package install logic
├── Install-DeveloperSoftware.ps1        # orchestrator
├── Install-DeveloperSoftware.Tests.ps1  # Pester tests for orchestrator
├── Models.Tests.ps1                     # Pester tests for classes
└── install.log                          # generated at runtime
```

### 6.2 — Running the Full Suite

```powershell
# run all tests
Invoke-Pester ./DevInstaller -Output Detailed

# dry run
. .\DevInstaller\Install-DeveloperSoftware.ps1
Install-DeveloperSoftware -WhatIf

# real run (elevated prompt recommended)
Install-DeveloperSoftware -Verbose
```

### 6.3 — Stretch Goals

Once you're comfortable with everything above, here are directions to take it further:

1. **Parallel installs** — use `ForEach-Object -Parallel` (requires PS 7+) with a thread-safe tracker using `[System.Collections.Concurrent.ConcurrentBag[SoftwarePackage]]`.
2. **Idempotent re-runs** — read the log file on startup and skip packages that previously succeeded in the same session date.
3. **Config-driven manifests** — load the package list from a JSON or YAML file instead of hardcoding it, so teams can customize their toolset.
4. **Progress bars** — use `Write-Progress` to show a visual progress bar during the install loop.
5. **Module packaging** — convert the project into a proper PowerShell module (`.psm1` + `.psd1` manifest) so it can be imported with `Import-Module`.

---

## Quick Reference: Pester Assertions

| Assertion | Use Case |
|---|---|
| `Should -Be $value` | Exact equality |
| `Should -BeTrue` | Boolean true |
| `Should -BeFalse` | Boolean false |
| `Should -BeNullOrEmpty` | Null/empty check |
| `Should -BeLike "*pattern*"` | Wildcard match |
| `Should -Contain $item` | Collection contains item |
| `Should -Throw` | Expects an exception |
| `Should -Not -Throw` | Expects no exception |
| `Should -Invoke CmdName -Times N` | Mock was called N times |

## Quick Reference: Common Gotchas

**"My function returns extra stuff."** — Uncaptured expressions go to the pipeline. Use `$null = SomeCommand` or `[void]SomeCommand` to suppress unwanted output.

**"My class isn't found in Pester."** — Classes must be dot-sourced in `BeforeAll`, not `BeforeEach`. And the class file must be a standalone `.ps1`, not inside a `.psm1` module (classes in modules have scoping quirks).

**"Mock doesn't seem to work on `winget`."** — Native executables can be mocked, but the mock replaces the command lookup. Make sure your mock is defined in the right scope (`Describe` or `Context` level) and before the code runs.

**"`$LASTEXITCODE` bleeds between tests."** — Reset it in `BeforeEach` with `$global:LASTEXITCODE = 0`.
