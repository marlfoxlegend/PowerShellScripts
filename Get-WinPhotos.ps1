Param(
	[Parameter(Position=0, Mandatory=$false)]
	[Int32] $searchDaysAgo = 21,
	[Parameter(Position=1, Mandatory=$false)]
	[Int32] $MinKB = 100,
	[Parameter(Position = 2, Mandatory = $false)]
	[Alias("UniqueName", "NewName", "Name")]
	[String] $OptionalPhotoName = "_SpotlightPicture_",
    [Parameter(Position = 3, Mandatory = $false)]
    [bool] $PrintSuccessful = $false
)

# Set up variables to use in script
$photoPath = Resolve-Path -Path "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.ContentDelivery*\LocalState\Assets\"
$dateCutOff = (Get-Date).Subtract($searchDaysAgo)
$day = "{0:yyyyMMdd}" -f ([System.DateTime]::Now)
$existingPhotoCount = 0
$userPhotos = "$env:USERPROFILE\Pictures\Win10Photos"

if (-not (Test-Path $userPhotos)) {
	New-Item -Path $userPhotos -ItemType Directory
} else {
    $existingPhotoCount = @(Get-ChildItem -Path "$userPhotos\*" -Name).Count
}

$MinKB = $MinKB * 1KB
# Load files into variable matching requirements
$files = @(Get-ChildItem -Path $photoPath -Force | Where-Object {
		($_.Length -ge $MinKB) -and ($_.CreationTime -ge $dateCutOff) })

# Copy the files and convert them to JPG
$fileCount = $files.Count
if ($fileCount -gt 0) {
    # Get the padding for the number appended to the file name
	$pad = [System.Math]::Floor([System.Math]::Log10($fileCount)) + 2
	$OptionalPhotoName = if (-not $OptionalPhotoName.StartsWith("_")) {"_" + $OptionalPhotoName + "_"} else {$OptionalPhotoName}
	$j = $existingPhotoCount + 1
	$passedFiles = [System.Collections.ArrayList]::new($fileCount)
	foreach ($file in $files) {
        $destFileName = "{0}{1}{2}.jpg" -f $day, $OptionalPhotoName, "$j".PadLeft($pad, "0")
		$destFile = Join-Path -Path $userPhotos -ChildPath $destFileName
		try {
			$passedFiles.Add((Copy-Item -Path $file.FullName -Destination $destFile))
		}
		catch [System.IO.IOException] {
			Write-Output "Couldn't Copy File: $($file.FullName) To Destination: $($destFile)"
			Write-Output $_.ErrorDetails.Message
			$passedFiles.RemoveAt($passedFiles.Count - 1)
		}
		$j += 1
	}
	if ($passedFiles.Count -ge 1) {
		Write-Output "$($passedFiles.Count)/$fileCount pictures copied successfully"
        if ($PrintSuccessful) {
            Write-Output $passedFiles
        }
	}
}
else {
	Write-Output "No files were found..."
}