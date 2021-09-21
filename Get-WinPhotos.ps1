function Get-SpotlightPictures {
    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("NewName")]
        [String] $RenameAs = "SpotlightPhoto",
        [switch] $OutputCopiedFiles
    )

    $SpotlightPhotosPath = Resolve-Path "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDelivery*\LocalState\Assets\"
    if ($null -eq $SpotlightPhotosPath) {
        Write-Error "Cannot resolve the Window's Spotlight directory path."
        return
    }

    $DestDirectory = New-Item "$env:USERPROFILE\Pictures\SpotlightPictures" -ItemType Directory -Force
    $DateCreated = "{0:yyyyMMdd}" -f ([System.DateTime]::Now)

    $ImageFiles = @(Get-ChildItem $SpotlightPhotosPath -File | 
            ForEach-Object {
                $Image = [System.Drawing.Image]::FromFile($_)
                $IsJpg = $Image.RawFormat -eq [System.Drawing.Imaging.ImageFormat]::Jpeg
                if ($IsJpg -and ($Image.Width -eq 1920)) {
                    $_
                }
            })
    $PassedFiles = 0
    Push-Location $DestDirectory
    for (($i = 0), ($j = 1); $i -lt $ImageFiles.Count; $i++) {
        $destFileName = "{0}_{1}_{2}.jpg" -f $DateCreated, $RenameAs, $j
        try {
            $Jpg = Copy-Item $ImageFiles[$i] -Destination $destFileName -PassThru
            $j++
            $PassedFiles++
            if ($OutputCopiedFiles) {
                "Copy Successful: {0}" -f $Jpg | Write-Host
            }
        } catch {
            Write-Warning $_.Exception.Message
        }
    }
    Pop-Location
    if ($ImageFiles.Count -ge 1) {
        Write-Host ("{0}/{1} pictures copied successfully." -f $PassedFiles, $ImageFiles.Count)
    }
    else {
        Write-Host "No files were found with specified criteria."
    }
}