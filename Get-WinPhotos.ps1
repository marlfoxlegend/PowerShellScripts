function Copy-SpotlightPictures {
    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $Name = "SpotlightPhoto"
    )

    try {
        $SpotlightPhotosPath = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDelivery*\LocalState\Assets\*"
        $Spotlights = Get-ChildItem $SpotlightPhotosPath
    }
    catch {
        Write-Host "Cannot resolve the Window's Spotlight directory path."
        return
    }

    $DestDirectory = New-Item "$env:USERPROFILE\Pictures\SpotlightPhotos" -ItemType Directory -Force
    $DateCreated = "{0:yyyyMMdd}" -f ([System.DateTime]::Today)

    $FileIndex = 1
    $TotalJpegs = 0
    $StackName = "Spotlights"
    Push-Location $DestDirectory -StackName $StackName
    $ImageFiles = $Spotlights | ForEach-Object {
        $Image = [System.Drawing.Image]::FromFile($_)
        $IsJpg = $Image.RawFormat -eq [System.Drawing.Imaging.ImageFormat]::Jpeg
        if ($IsJpg -and ($Image.Width -eq 1920)) {
            $TotalJpegs++
            $NewName = "{0}_{1}_{2}.jpg" -f $DateCreated, $Name, ("$FileIndex".PadLeft(2, '0'))
            try {
                $Jpg = Copy-Item $_ $NewName -PassThru -ErrorAction Stop
                $FileIndex++
            }
            catch {
                Write-Error $_.Exception.Message
                continue
            }
            "Copy Successful: {0}" -f $Jpg | Write-Verbose
            $Jpg
        }
    }
    Pop-Location -StackName $StackName
    if ($TotalJpegs -ge 1) {
        Write-Host ("{0}/{1} pictures copied successfully." -f $ImageFiles.Count, $TotalJpegs)
    }
    else {
        Write-Host "No files were found with specified criteria."
    }
}