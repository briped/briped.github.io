$global:ApiKey = Get-Content -TotalCount 1 -Path (Join-Path -Path $PSScriptRoot -ChildPath '.apiKey')
$global:RssBase = [uri]'https://xmpl.dk/podcast/'
$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'DRPodcast.psd1')
Import-Module -Force -Name $Manifest
$Walled = Get-Content -Raw -Encoding utf8 -Path (Join-Path -Path $PSScriptRoot -ChildPath 'walled.json') | ConvertFrom-Json

$Podcasts = $Walled | 
	Sort-Object -Unique id | 
	Sort-Object -Property title | 
	Get-DRPodcast

foreach ($Podcast in $Podcasts) {
	$Feed = Join-Path -Path $FeedsPath -ChildPath "$($Podcast.sSlug).xml"
	$Podcast | Add-Member -NotePropertyName episodes -NotePropertyValue $(Get-DREpisode -Id $Podcast.id -Limit 10000)
	$Podcast | New-DRRss | Out-File -Force -Encoding utf8 -FilePath $Feed
}
$Html = Join-Path -Path $FeedsPath -ChildPath "index.html"
$Podcasts | New-DRHtml | Out-File -Force -Encoding utf8 -FilePath $Html
