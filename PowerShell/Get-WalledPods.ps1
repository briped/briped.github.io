$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'DRPodcast.psd1')
Import-Module -Force -Name $Manifest
$WalledPath = Join-Path -Path $PSScriptRoot -ChildPath 'walled.json'
$WatermarkPath = Join-Path -Path $PodPath -ChildPath 'assets' -AdditionalChildPath 'icon-recycle-469x454.png'
function Get-WalledPodcast {
	$Podcasts = Search-DRPodcast -Type series -Query * -Limit 10000 | Where-Object podcastUrl
	foreach ($Podcast in $Podcasts) {
		$Response = Invoke-WebRequest -Uri $Podcast.podcastUrl
		if ($Response.Content -notmatch 'utm_source=thirdparty') { continue }
		$CoverOrig = Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).original.jpg"
		$CoverPath = Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).jpg"
		Invoke-WebRequest -Uri $Podcast.imageUri -OutFile $CoverOrig
		Add-Watermark -ImagePath $CoverOrig -WatermarkPath $WatermarkPath -OutputPath $CoverPath -PositionX 0 -PositionY 10 -Width 180 -Opacity 70
		Remove-Item -Path $CoverOrig
		$Podcast | Select-Object -Property title, @{N='slug'; E={$Podcast.slug.Replace("-$($Podcast.productionNumber)", '')}}, id
	}
}
Get-WalledPodcast | ConvertTo-Json | Out-File -Encoding utf8 -FilePath $WalledPath