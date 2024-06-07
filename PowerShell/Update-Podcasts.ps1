$global:ApiKey = Get-Content -TotalCount 1 -Path (Join-Path -Path $PSScriptRoot -ChildPath '.apiKey')
$global:RssBase = [uri]'https://xmpl.dk/podcast/'
$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'DRPodcast.psd1')
Import-Module -Force -Name $Manifest
<#
$Walled = Get-Content -Raw -Encoding utf8 -Path (Join-Path -Path $PSScriptRoot -ChildPath 'walled.json') | ConvertFrom-Json

$Podcasts = $Walled | 
	Sort-Object -Unique id | 
	Sort-Object -Property title | 
	Get-DRPodcast
#>
$VerbosePreference = 'Continue'
foreach ($Podcast in $Podcasts) {
	Write-Verbose -Message "Adding episodes to $($Podcast.sSlug)"
	if (!($Podcast | Get-Member -Name 'episodes')) {
		$Podcast | Add-Member -NotePropertyName episodes -NotePropertyValue $(Get-DREpisode -Id $Podcast.id -Limit 10000)
	}
	Write-Verbose -Message "Output $($Podcast.sSlug) to JSON"
	$Podcast | ConvertTo-Json -Depth 10 | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).json")
	Write-Verbose -Message "Output $($Podcast.sSlug) to RSS"
	#$Podcast | New-DRRss | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).xml")
	$Podcast | New-DRRss | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).TEST.xml")
}
#$Podcasts | New-DRHtml | Out-File -Force -Encoding utf8 -FilePath $(Join-Path -Path $PodPath -ChildPath "index.html")
