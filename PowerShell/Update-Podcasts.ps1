$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'DRPodcast.psd1')
Import-Module -Force -Name $Manifest

$Walled = Get-Content -Raw -Encoding utf8 -Path (Join-Path -Path $PSScriptRoot -ChildPath 'walled.json') | ConvertFrom-Json
$Podcasts = $Walled | 
	Sort-Object -Unique id | 
	Sort-Object -Property title | 
	Get-DRPodcast

foreach ($Podcast in $Podcasts) {
	if (!$Podcast.episodes) {
		Write-Verbose -Message "Adding episodes to '$($Podcast.title)'."
		$Podcast | Add-Member -NotePropertyName episodes -NotePropertyValue $(Get-DREpisode -Id $Podcast.id -Limit 10000)
	}
	$JsonPath = Join-Path -Path $PodPath -ChildPath 'data' -AdditionalChildPath "$($Podcast.sSlug).json"
	$OldJson = Get-Content -Encoding utf8 -Path $JsonPath | ConvertFrom-Json -Depth 10
	$NewJson = $Podcast | ConvertTo-Json -Depth 10
	if (!(Compare-Object -ReferenceObject $OldJson -DifferenceObject $Podcast)) {
		$NewJson | Out-File -Force -Encoding utf8 -FilePath $JsonPath
		$Podcast | New-DRRss | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).xml")
	}
}
$Podcasts | New-DRHtml | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "index.html")
