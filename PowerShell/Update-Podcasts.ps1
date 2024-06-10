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
	$Json = Join-Path -Path $PodPath -ChildPath 'data' -AdditionalChildPath "$($Podcast.sSlug).json"
	$Old = Get-Content -Encoding utf8 -Path $Json | ConvertFrom-Json -Depth 10
	$Comparison = Compare-Object -ReferenceObject $Old.latestEpisodeStartTime -DifferenceObject $Podcast.latestEpisodeStartTime
	if ($Comparison) {
		$Podcast | ConvertTo-Json -Depth 10 | Out-File -Force -Encoding utf8 -FilePath $Json
		$Podcast | New-DRRss | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).xml")
	}
}
$Podcasts | New-DRHtml | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "index.html")
