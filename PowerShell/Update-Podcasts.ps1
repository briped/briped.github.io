$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'DRPodcast.psd1')
Import-Module -Force -Name $Manifest
$Favorites = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'favorites.json')
$FeedsPath = [System.IO.FileInfo](Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent -ChildPath 'podcast')

Get-Content -Encoding utf8 -Path $Favorites.FullName | 
	ConvertFrom-Json | 
	Get-DRPodcast | 
	ForEach-Object {
		$Feed = Join-Path -Path $FeedsPath -ChildPath "$($_.sslug).xml"
		$_ | Add-Member -NotePropertyName episodes -NotePropertyValue $(Get-DREpisode -Id $_.id -Limit 10000)
		$_ | New-DRRSSFeed | Out-File -Force -Encoding utf8 -FilePath $Feed
	}
