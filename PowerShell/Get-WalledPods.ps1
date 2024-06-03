function Get-WalledPods {
	$Pods = Search-DRPodcast -Type series -Query * -Limit 10000 | Where-Object podcastUrl
	foreach ($p in $Pods) {
		$r = Invoke-WebRequest -Uri $p.podcastUrl
		if ($r.Content -match 'utm_source=thirdparty') {
			$p | Select-Object -Property title, @{N='slug'; E={$p.slug.Replace("-$($p.productionNumber)", '')}}, id
		}
	}
}
Get-WalledPods | ConvertTo-Json | Out-File -Encoding utf8 -FilePath walled.json