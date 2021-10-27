function Copy-SpotlightPictures {
    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $Name = "Spotlight",
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Destination = 'Pictures\SpotlightPhotos'
    )

    try {
        $SpotlightDirectory = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDelivery*\LocalState\Assets\*"
        $Spotlights = @(Get-ChildItem -Path $SpotlightDirectory).FullName
    }
    catch {
        Write-Host $_.Exception.Message
        return
    }
    Write-Debug "Collected $($Spotlights.Count) files."

    $Dest = if (!($Destination.Substring(0, 2) -ilike "?:")) {
        "$env:USERPROFILE\$Destination"
    }
    else {
        $Destination
    }
    $DestDirectory = New-Item $Dest -ItemType Directory -Force
    $DateCreated = "{0:yyyyMMdd}" -f ([System.DateTime]::Today)

    $FileIndex = 1
    $TotalJpegs = 0
    $Spotlights | ForEach-Object {
        try {
            $Image = [System.Drawing.Image]::FromFile($_)
            Write-Debug ("{0}; {1}" -f $Image.ToString(), $Image.PhysicalDimension)
        }
        catch {
            Write-Warning $_.Exception.Message
            continue
        }
        $IsJpg = $Image.RawFormat -eq [System.Drawing.Imaging.ImageFormat]::Jpeg
        if ($IsJpg -and ($Image.Width -eq 1920)) {
            $TotalJpegs++
            $NewName = "{0}_{1}_{2}.jpg" -f $DateCreated, $Name, ("$FileIndex".PadLeft(2, '0'))
            try {
                $Jpg = Copy-Item $_ "$DestDirectory\$NewName" -PassThru
                $FileIndex++
            }
            catch {
                Write-Debug -Exception $_.Exception
                continue
            }
            Write-Information "Copied: $($_.Split('\')[-1])`nTo: $Jpg`n"
        } 1> $null
    }
    if ($TotalJpegs -ge 1) {
        Write-Information ("$($FileIndex - 1)/$TotalJpegs pictures copied successfully.")
    }
    else {
        Write-Information "No files were found with specified criteria."
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

Function gig {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$TemplateNames,
        [Parameter()]
        [switch]$PassThru
    )
    $Uri = "https://www.toptal.com/developers/gitignore/api/"
    $Params = ($TemplateNames | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
    $Content = Invoke-WebRequest -Uri ($Uri + $Params) | Select-Object -ExpandProperty content
    if ($PassThru) {
        Write-Output $Content
    } else {
        Out-File -InputObject $Content `
            -FilePath (Join-Path -Path $PWD -ChildPath ".gitignore") `
            -Encoding ascii
    }
}