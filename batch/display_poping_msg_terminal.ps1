$message = "Nimetoka kiasi, nitarudi, i'll call when am back"

while ($true) {
    $width  = $Host.UI.RawUI.WindowSize.Width
    $height = $Host.UI.RawUI.WindowSize.Height

    Clear-Host
    $paddingTop = [Math]::Floor($height / 2)
    $paddingLeft = [Math]::Floor(($width - $message.Length) / 2)

    for ($i = 0; $i -lt $paddingTop; $i++) { Write-Host "" }

    Write-Host (" " * $paddingLeft) -NoNewline
    Write-Host $message.ToUpper() -ForegroundColor Red -BackgroundColor Black

    Start-Sleep -Milliseconds 900

    Clear-Host
    Start-Sleep -Milliseconds 700

    if ($Host.UI.RawUI.KeyAvailable) {
        [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        break
    }
}
