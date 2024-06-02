$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'DRPodcast.psd1')
Import-Module -Force -Name $Manifest
$Favorites = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'favorites.json')
$FeedsPath = [System.IO.FileInfo](Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent -ChildPath 'podcast')

$Podcasts = Get-Content -Encoding utf8 -Path $Favorites.FullName | 
	ConvertFrom-Json | 
	Get-DRPodcast

foreach ($Podcast in $Podcasts) {
	$Feed = Join-Path -Path $FeedsPath -ChildPath "$($Podcast.sSlug).xml"
	$Podcast | Add-Member -NotePropertyName episodes -NotePropertyValue $(Get-DREpisode -Id $Podcast.id -Limit 10000)
	$Podcast | New-DRRss | Out-File -Force -Encoding utf8 -FilePath $Feed
}
$Html = Join-Path -Path $FeedsPath -ChildPath "index.html"
$Podcasts | New-DRHtml | Out-File -Force -Encoding utf8 -FilePath $Html
