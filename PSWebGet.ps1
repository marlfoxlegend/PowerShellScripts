function wget()
{
	Param(
		[Parameter(Mandatory = $true)]
		[System.String]
		$url,
		[Parameter(Mandatory = $false)]
		[System.String]
		$destPath
	)
	if ($destPath -eq "")
 {
		$destPath = (Get-Location).Path
 }
 elseif (@(Split-Path -Path $destPath)[0] -notlike "C:")
 {
	 $destPath = Resolve-Path -Path $destPath;
 }
 $i = $url.LastIndexOf("/") + 1;
 $name = $url.Substring($i);
 $destPath = Join-Path $destPath -ChildPath $name;
 (New-Object System.Net.WebClient).DownloadFile($url, $destPath);
}