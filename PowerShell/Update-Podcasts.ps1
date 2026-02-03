$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'DRPodcast.psd1')
Import-Module -Force -Name $Manifest


$WalledJsonPath = Join-Path -Path $PSScriptRoot -ChildPath 'walled.json'
Write-Verbose -Message "Reading ${WalledJsonPath}"
$Walled = Get-Content -Raw -Encoding utf8 -Path $WalledJsonPath | ConvertFrom-Json

Write-Verbose -Message "Fetching podcasts"
$Podcasts = $Walled | 
	Sort-Object -Unique id | 
	Sort-Object -Property title | 
	Get-DRPodcast

Write-Verbose -Message "Looping through fetched podcasts"
foreach ($Podcast in $Podcasts) {
	if (!$Podcast.episodes) {
		try {
			$Episodes = Get-DREpisode -Id $Podcast.id -Limit 10000
		}
		catch {
			Write-Warning -Message "Failed getting episodes for $($Podcast.title) ($($Podcast.id)). Skipping."
			continue
		}
		Write-Verbose -Message "Adding episodes to '$($Podcast.title)'."
		$Podcast | Add-Member -NotePropertyName episodes -NotePropertyValue $Episodes
	}
	$PodcastJsonPath = Join-Path -Path $PodPath -ChildPath 'data' -AdditionalChildPath "$($Podcast.sSlug).json"
	$PodcastXmlPath = Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).xml"
	Write-Verbose "Testing if ${PodcastJsonPath} exists."
	$Exists = Test-Path -PathType Leaf -Path $PodcastJsonPath
	if ($Exists) {
		Write-Verbose -Message "Reading ${PodcastJsonPath}"
		$Old = Get-Content -Encoding utf8 -Path $PodcastJsonPath | ConvertFrom-Json -Depth 10
		Write-Verbose -Message "Comparing $($Old.latestEpisodeStartTime) with $($Podcast.latestEpisodeStartTime)"
		$Changed = Compare-Object -ReferenceObject $Old.latestEpisodeStartTime -DifferenceObject $Podcast.latestEpisodeStartTime
	}
	if ($Changed -or !$Exists) {
		Write-Verbose -Message "Writing/updating ${PodcastJsonPath}"
		$Podcast | ConvertTo-Json -Depth 10 | Out-File -Force -Encoding utf8 -FilePath $PodcastJsonPath
		Write-Verbose -Message "Writing ${PodcastXmlPath}"
		$Podcast | New-DRRss | Out-File -Force -Encoding utf8 -FilePath $PodcastXmlPath
	}
}
$Podcasts | New-DRHtml | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "index.html")
