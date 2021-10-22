﻿function Copy-SpotlightPictures {
    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $Name = "SpotlightPictures"
    )

    try {
        $SpotlightDirectory = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDelivery*\LocalState\Assets\*"
        $Spotlights = Get-ChildItem -Path $SpotlightFiles
    }
    catch {
        Write-Error "Cannot resolve the Window's Spotlight directory path:`n`t$SpotlightDirectory"
        return
    }

    $DestDirectory = New-Item "$env:USERPROFILE\Pictures\SpotlightPictures" -ItemType Directory -Force
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
                Write-Error -Exception $_.Exception
                continue
            }
            Write-Information "Copy Successful: $Jpg"
            $Jpg
        }
    }
    Pop-Location -StackName $StackName
    if ($TotalJpegs -ge 1) {
        Write-Debug ("$($ImageFiles.Count)/$TotalJpegs pictures copied successfully.")
    }
    else {
        Write-Debug "No files were found with specified criteria."
    }
}

function wget {
    Param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $url,
        [Parameter(Mandatory = $false)]
        [System.String]
        $destPath
    )
    if ($destPath -eq "") {
        $destPath = (Get-Location).Path
    }
    elseif (@(Split-Path -Path $destPath)[0] -notlike "C:") {
        $destPath = Resolve-Path -Path $destPath;
    }
    $i = $url.LastIndexOf("/") + 1;
    $name = $url.Substring($i);
    $destPath = Join-Path $destPath -ChildPath $name;
 (New-Object System.Net.WebClient).DownloadFile($url, $destPath);
}