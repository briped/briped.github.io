$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'DRPodcast.psd1')
Import-Module -Force -Name $Manifest
$WalledPath = Join-Path -Path $PSScriptRoot -ChildPath 'walled.json'
$WatermarkPath = Join-Path -Path $PodPath -ChildPath 'assets' -AdditionalChildPath 'icon-recycle-469x454.png'
function Get-WalledPodcast {
	$Podcasts = Search-DRPodcast -Type series -Query * -Limit 10000 | Where-Object podcastUrl
	foreach ($Podcast in $Podcasts) {
		# Get the original RSS feed.
		$Response = Invoke-WebRequest -Uri $Podcast.podcastUrl
		# Check if the podcast is walled. Skip if not walled.
		if ($Response.Content -notmatch 'utm_source=thirdparty') { continue }
		foreach ($Image in $Podcast.imageAssets) {
			# Set the unique image name.
			$ImageName = "$($Podcast.sSlug)_$($Image.ratio.Replace(':', '-'))_$($Image.target.ToLower())_$(($Image.id -split ':')[-1]).$(($Image.format -split '/')[-1])"
			# Download the image.
			Invoke-WebRequest -Uri $Image.uri -OutFile $(Join-Path -Path $PodPath -ChildPath '.source' -AdditionalChildPath $ImageName)
		}
		Add-DRWatermark -PositionX 0 -PositionY 10 -Width 180 -Opacity 70 -ImagePath $CoverOrig -WatermarkPath $WatermarkPath -OutputPath $(Join-Path -Path $PodPath -ChildPath 'cover' -AdditionalChildPath "$($Podcast.sSlug).jpg")
		$Podcast | Select-Object -Property title, @{N='slug'; E={$Podcast.slug.Replace("-$($Podcast.productionNumber)", '')}}, id
	}
}
Get-WalledPodcast | ConvertTo-Json | Out-File -Encoding utf8 -FilePath $WalledPath
