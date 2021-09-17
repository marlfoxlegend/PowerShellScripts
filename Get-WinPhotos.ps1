Param(
	[Parameter(Position = 0)]
	[ValidateNotNullOrEmpty()]
	[Alias("UniqueFileName", "NewFileName", "FileName")]
	[String] $RenameAs = "SpotlightPhoto",
	[Parameter()]
	[ValidateRange("Positive")]
	[Int32] $SearchDaysAgo = 30,
	[Parameter()]
	[Int32] $MinSize = 100,
	[Parameter()]
	[switch] $OutputCopiedFiles
)

# Set up variables to use in script
$spotlightPhotosPath = Resolve-Path -Path "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDelivery*\LocalState\Assets\"
$userPhotoPath = "$env:USERPROFILE\Pictures\Win10Photos"

$dateCreated = "{0:yyyyMMdd}" -f ([System.DateTime]::Now)
$RenameAs.Trim("_")

$dateCutOff = (Get-Date).AddDays(-$SearchDaysAgo)
$MinKB = $MinSize * 1KB

$destDirectory = if (-not (Test-Path $userPhotoPath))
{
	New-Item -Path $userPhotoPath -ItemType Directory
}
else
{
	Get-Item -Path $userPhotoPath
}
$existingPhotoCount = @(Get-ChildItem $destDirectory -Filter "*.jpg" -Name).Count

# Load files into variable matching requirements
$files = @(Get-ChildItem -Path $spotlightPhotosPath -Force -File | 
		Where-Object { ($_.Length -ge $MinKB) -and ($_.CreationTime -ge $dateCutOff) })

# Get the number of 0's to pad the file name index.
$pad = [System.Math]::Floor([System.Math]::Log10($existingPhotoCount + $files.Count)) + 2
$index = $existingPhotoCount + 1
$passedFiles = 0
		
foreach ($file in $files)
{
	$destFileName = "{0}_{1}_{2}.jpg" -f $dateCreated, $RenameAs, "$index".PadLeft($pad, "0")
	$destFilePath = Join-Path $destDirectory.FullName $destFileName
	try
	{
		$copiedFile = $file.CopyTo($destFilePath)
		$passedFiles += 1
		$index += 1
	}
	catch [System.IO.IOException]
	{
		Write-Warning $_.ErrorDetails.Message
		continue
	}

	if ($OutputCopiedFiles)
	{
		$msg = "Copy Successful: {0}" -f $copiedFile.FullName
		Write-Host $msg
	}
}
if ($files.Count -ge 1)
{
	Write-Host ("{0}/{1} pictures copied successfully." -f $passedFiles, $files.Count)
}
else
{
	Write-Host "No files were found with specified criteria."
}