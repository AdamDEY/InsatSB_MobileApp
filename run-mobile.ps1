param(
  [string]$DeviceId,
  [int]$Port = 5000,
  [string]$Target = 'lib/main.dart',
  [switch]$DryRun,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs
)

$ErrorActionPreference = 'Stop'

function Require-Command {
  param([Parameter(Mandatory = $true)][string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required command '$Name' was not found in PATH."
  }
}

Require-Command -Name 'adb'
Require-Command -Name 'flutter'

$selectedDevice = $DeviceId

if (-not $selectedDevice) {
  $connectedDevices = @(
    (& adb devices) |
      Select-String '\tdevice$' |
      ForEach-Object { ($_ -split '\t')[0].Trim() } |
      Where-Object { $_ -ne '' }
  )

  if ($connectedDevices.Count -eq 1) {
    $selectedDevice = $connectedDevices[0]
    Write-Host "Using detected Android device: $selectedDevice"
  } elseif ($connectedDevices.Count -gt 1) {
    $selectedDevice = $connectedDevices[0]
    Write-Host "Multiple Android devices detected. Using first device: $selectedDevice"
    Write-Host "Tip: pass -DeviceId <id> to choose another device."
  } else {
    Write-Host 'No Android device detected via adb. Skipping adb reverse.'
  }
}

if ($selectedDevice) {
  Write-Host "Running adb reverse on device $selectedDevice for tcp:$Port ..."
  & adb -s $selectedDevice reverse "tcp:$Port" "tcp:$Port" | Out-Host
} else {
  Write-Host 'No device selected for adb reverse.'
}

$runArgs = @('run', '-t', $Target)
if ($selectedDevice) {
  $runArgs += @('-d', $selectedDevice)
}
if ($FlutterArgs) {
  $runArgs += $FlutterArgs
}

if ($DryRun) {
  $joined = $runArgs -join ' '
  Write-Host "Dry run complete. Flutter command would be: flutter $joined"
  exit 0
}

Write-Host 'Starting Flutter app...'
& flutter @runArgs
exit $LASTEXITCODE
