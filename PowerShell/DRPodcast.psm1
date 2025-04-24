if ($global:ApiKey.Length -ne 32) {
    if ($null -ne $env:API_KEY -and $env:API_KEY.Length -eq 32) {
        $global:ApiKey = $env:API_KEY
    }
    elseif (Test-Path -PathType Leaf -Path (Join-Path -Path $PSScriptRoot -ChildPath '.apiKey')) {
        $global:ApiKey = Get-Content -TotalCount 1 -Path (Join-Path -Path $PSScriptRoot -ChildPath '.apiKey')
    }
    else {
        throw 'API key missing.'
    }
}
$global:PodBase = [uri]'https://xmpl.dk/podcast/'
$global:PodPath = [System.IO.FileInfo](Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent -ChildPath 'podcast')
$global:ApiBase = [uri]'https://api.dr.dk/radio/v2'
$global:ImgBase = [uri]'https://asset.dr.dk/imagescaler/'
$global:Headers = @{
    'x-apikey' = $ApiKey
}
function Search-Podcast {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('q')]
        [string]
        $Query
        ,
        [Parameter()]
        [ValidateSet('series', 'episodes')]
        [Alias('t')]
        [string]
        $Type = 'series'
        ,
        [Parameter()]
        [Alias('l')]
        [int]
        $Limit
    )
    begin {
        $Splatter = @{
            ContentType = 'application/json; charset=utf-8'
            Headers     = $Headers
            Method      = 'GET'
            Uri         = "$($ApiBase)/search/$($Type)"
        }
        $QueryCollection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        $UriBuilder = [System.UriBuilder]$Splatter.Uri
    }
    process {
        $QueryCollection.Add('q', $Query)
        if ($Limit -gt 0) { $QueryCollection.Add('limit', $Limit) }
        $UriBuilder.Query = $QueryCollection.ToString()
        $Splatter.Uri = $UriBuilder.Uri
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-RestMethod @$($Splatter | ConvertTo-Json -Compress)"
        $Response = Invoke-RestMethod @Splatter
        
        foreach ($Podcast in $Response.items) {
            $Sslug = $Podcast.slug.Replace("-$($Podcast.productionNumber)", '')
            $RssPath = ([uri]"$($PodBase.AbsoluteUri)/$($Sslug).xml").LocalPath -split '/' | Where-Object { $_ }
            $RssUri = [uri]"$($PodBase.Scheme)://$($PodBase.Host)/$($RssPath -join '/')"
            Set-ImageAssetUri -Podcast $Podcast
            $ImageAsset = $Podcast.imageAssets | Where-Object target -eq 'podcast'
            $ImageUri = $ImageAsset.Uri
            Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Adding property: sSlug = $($Sslug))"
            $Podcast | Add-Member -NotePropertyName sSlug -NotePropertyValue $Sslug
            Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Adding property: imageUri = $($ImageUri))"
            $Podcast | Add-Member -NotePropertyName imageUri -NotePropertyValue $ImageUri
            Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Adding property: rssUri = $($RssUri))"
            $Podcast | Add-Member -NotePropertyName rssUri -NotePropertyValue $RssUri
            $Podcast
        }
    }
    end {}
}
function Get-Podcast {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true
                  ,ValueFromPipeline = $true
                  ,ValueFromPipelineByPropertyName = $true
                  ,ValueFromRemainingArguments = $false
                  ,Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Id
    )
    begin {
        $Splatter = @{
            ContentType = 'application/json; charset=utf-8'
            Headers     = $Headers
            Method      = 'GET'
        }
    }
    process {
        $Splatter.Uri = "$($ApiBase)/series/$($Id)"
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-RestMethod @$($Splatter | ConvertTo-Json -Compress)"
        $Podcast = Invoke-RestMethod @Splatter

        $Sslug = $Podcast.slug.Replace("-$($Podcast.productionNumber)", '')
        $RssPath = ([uri]"$($PodBase.AbsoluteUri)/$($Sslug).xml").LocalPath -split '/' | Where-Object { $_ }
        $RssUri = [uri]"$($PodBase.Scheme)://$($PodBase.Host)/$($RssPath -join '/')"

        Set-ImageAssetUri -Podcast $Podcast
        <#
        $ApiPath = ([uri]"$($ApiBase.AbsoluteUri)/images/raw/$($ImageAsset.id)").LocalPath -split '/' | Where-Object { $_ }
        $QueryCollection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        $QueryCollection.Add('protocol', $ApiBase.Scheme)
        $QueryCollection.Add('server', $ApiBase.Host)
        $QueryCollection.Add('file', "/$($ApiPath -join '/')")
        $QueryCollection.Add('scaleAfter', 'crop')
        $QueryCollection.Add('quality', 70)
        $QueryCollection.Add('w', 720)
        $QueryCollection.Add('h', 720)
        $UriBuilder = [System.UriBuilder]$ImgBase
        $UriBuilder.Query = $QueryCollection.ToString()
        $ImageUri = $UriBuilder.Uri
        #>
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Adding property: sSlug = $($Sslug))"
        $Podcast | Add-Member -NotePropertyName sSlug -NotePropertyValue $Sslug
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Adding property: rssUri = $($RssUri))"
        $Podcast | Add-Member -NotePropertyName rssUri -NotePropertyValue $RssUri
        $Podcast
    }
    end {}
}
function Get-Episode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true
                  ,ValueFromPipeline = $true
                  ,ValueFromPipelineByPropertyName = $true
                  ,ValueFromRemainingArguments = $false
                  ,Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Id
        ,
        [Parameter()]
        [Alias('l')]
        [int]
        $Limit
    )
    begin {
        $Splatter = @{
            ContentType = 'application/json; charset=utf-8'
            Headers     = $Headers
            Method      = 'GET'
        }
        $QueryCollection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
    }
    process {
        $Splatter.Uri = "$($ApiBase)/series/$($Id)/episodes"
        if ($Limit -gt 0) { $QueryCollection.Add('limit', $Limit) }
        $UriBuilder = [System.UriBuilder]$Splatter.Uri
        $UriBuilder.Query = $QueryCollection.ToString()
        $Splatter.Uri = $UriBuilder.Uri
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-RestMethod @$($Splatter | ConvertTo-Json -Compress)"
        $Response = Invoke-RestMethod @Splatter
        $Response.items
    }
    end {}
}
function New-Rss {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true
                  ,ValueFromPipeline = $true
                  ,ValueFromPipelineByPropertyName = $true
                  ,ValueFromRemainingArguments = $false
                  ,Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $Podcast
    )
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Generating RSS for '$($Podcast.title)'."
    #https://www.rssboard.org/
    function repl {
        param(
            [string]$String
        )
        $String.Replace('&', '&#x26;').Replace('<', '&#x3C;').Replace('>', '&#x3E;')
    }
    $TitleSuffix = ' (recycled)'
    $DescriptionSuffix = "`r`n`r`n<a href=`"$($PodBase)`">Recycled</a> DR Podcast."
    $Title = repl($Podcast.title + $TitleSuffix)
    $Description = repl($Podcast.description + $DescriptionSuffix)
    $ImageAsset = $Podcast.imageAssets | Where-Object { $_.ratio -eq '1:1' -and $_.target -eq 'Podcast' }
    $ImageUri = $ImageAsset.uri.AbsoluteUri.Replace($ImageAsset.uri.Query, $ImageAsset.uri.Query.Replace('&', '&#x26;'))
    if (Test-Path -PathType Leaf -Path (Join-Path -Path $PodPath -ChildPath 'cover' -AdditionalChildPath "$($Podcast.sSlug).jpg")) {
        $ImageUri = "$($PodBase.Scheme)://$($PodBase.Host)/$((([uri]"$($PodBase.AbsoluteUri)/cover/$($Podcast.sSlug).jpg").AbsolutePath -split '/' | Where-Object { $_ }) -join '/')"
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): ImageUri: $($ImageUri)"
    $Rss = @"
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" 
    xmlns:atom="http://www.w3.org/2005/Atom" 
    xmlns:media="http://search.yahoo.com/mrss/" 
    xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
    <channel>
        <atom:link href="$($Podcast.rssUri)" 
            rel="self" 
            type="application/rss+xml" />
        <title>$($Title)</title>
        <link>$($Podcast.presentationUrl)</link>
        <description>$($Description)</description>
        <language>da</language>
        <copyright>DR</copyright>
        <managingEditor>podcast@dr.dk</managingEditor>
        <lastBuildDate>$((Get-Date).ToString("ddd, dd MMM yyyy HH:mm:ss zzz"))</lastBuildDate>
        <itunes:explicit>$($Podcast.explicitContent)</itunes:explicit>
        <itunes:author>DR</itunes:author>
        <itunes:owner>
            <itunes:email>podcast@dr.dk</itunes:email>
            <itunes:name>DR</itunes:name>
        </itunes:owner>
        <itunes:new-feed-url>$($Podcast.rssUri)</itunes:new-feed-url>
        <image>
            <url>$($ImageUri)</url>
            <title>$($Title)</title>
            <link>$($Podcast.presentationUrl)</link>
        </image>
        <itunes:image href="$($ImageUri)" />
        <media:restriction type="country" relationship="allow">dk</media:restriction>
"@
    foreach ($Category in $Podcast.categories) {
        $Rss += @"

        <category>$($Category)</category>
        <itunes:category text="$($Category)" />
"@
    }
    foreach ($Episode in $Podcast.episodes) {
        $Rss += @"

        <item>
            <guid isPermaLink="false">$($Episode.productionNumber)</guid>
            <link>$($Episode.presentationUrl)</link>
            <title>$(repl($Episode.title))</title>
            <description>$(repl($Episode.description))</description>
            <pubDate>$($Episode.publishTime.ToString("ddd, dd MMM yyyy HH:mm:ss zzz"))</pubDate>
            <itunes:explicit>$($Episode.explicitContent)</itunes:explicit>
            <itunes:author>DR</itunes:author>
            <itunes:duration>$((New-TimeSpan -Milliseconds $Episode.durationMilliseconds).ToString('hh\:mm\:ss'))</itunes:duration>
            <media:restriction type="country" relationship="allow">dk</media:restriction>
"@
        $AudioAssets = $Episode.audioAssets | Where-Object -Property target -EQ -Value 'Progressive'
        $AudioArray  = $AudioAssets | Where-Object -Property format -EQ 'mp3' | Sort-Object -Property bitrate -Descending
        $AudioArray += $AudioAssets | Where-Object -Property format -EQ 'mp4' | Sort-Object -Property bitrate -Descending
        foreach ($AudioAsset in $AudioArray) {
            $ContentType = if ($AudioAsset.format -eq 'mp4') { 'audio/x-m4a' } else { 'audio/mpeg' }
            $Rss += @"

            <enclosure url="$($AudioAsset.url)" 
                type="$($ContentType)" 
                length="$($AudioAsset.fileSize)" />
"@
        }
        $Rss += @"

        </item>
"@
    }
    $Rss += @"

    </channel>
</rss>
"@
    $Rss
}
function New-HtmlOld {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true
                  ,ValueFromPipeline = $true
                  ,ValueFromPipelineByPropertyName = $true
                  ,ValueFromRemainingArguments = $false
                  ,Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $Podcast
    )
    begin {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Generating HTML for $($Podcast.Count) podcasts."
        $Html = @"
<!DOCTYPE html>
<html lang="da">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>DR Lyd - Recycled</title>
        <link rel="icon" href="assets/icon-recycle.svg">
        <link rel="stylesheet" href="stylesheet.css">
    </head>
    <body>
        <header class="header">
            <h1 class="title">DR Lyd - Recycled</h1>
        </header>
        <div class="grid-container">
"@
    }
    process {
        $ImageAsset = $Podcast.imageAssets | Where-Object { $_.ratio -eq '1:1' -and $_.target -eq 'Podcast' }
        $ImageUri = $ImageAsset.uri.AbsoluteUri.Replace($ImageAsset.uri.Query, $ImageAsset.uri.Query.Replace('&', '&#x26;'))
        if (Test-Path -PathType Leaf -Path (Join-Path -Path $PodPath -ChildPath 'cover' -AdditionalChildPath "$($Podcast.sSlug).jpg")) {
            $ImageUri = "$($PodBase.Scheme)://$($PodBase.Host)/$((([uri]"$($PodBase.AbsoluteUri)/cover/$($Podcast.sSlug).jpg").AbsolutePath -split '/' | Where-Object { $_ }) -join '/')"
        }
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): ImageUri: $($ImageUri)"
        $Html += @"

            <div class="grid-item" title="$($Podcast.title) - $($Podcast.numberOfEpisodes) episoder">
                <div class="podcast-container">
                    <a href="$($Podcast.rssUri)"><img src="$($ImageUri)" alt="$($Podcast.title)"></a>
                    <a href="overcast://x-callback-url/add?url=$([uri]::EscapeDataString($Podcast.rssUri))"><div class="icon-app-overcast"></div></a>
                    <a href="pktc://subscribe/$($Podcast.rssUri.Host)$($Podcast.rssUri.PathAndQuery)"><div class="icon-app-pktc"></div></a>
                    <div class="podcast-episodes">$($Podcast.numberOfEpisodes)</div>
                </div>
                <div class="podcast-name">
                    <a href="$($Podcast.presentationUrl)" target="_blank">
                        <div class="icon-logo-drlyd"></div>
                        $($Podcast.title)
                    </a>
                </div>
            </div>
"@
    }
    end {
        $Html += @"

        </div>
    </body>
</html>
"@
        $Html
    }
}
function New-Html {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true
                  ,ValueFromPipeline = $true
                  ,ValueFromPipelineByPropertyName = $true
                  ,ValueFromRemainingArguments = $false
                  ,Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $Podcast
    )
    begin {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Generating HTML for $($Podcast.Count) podcasts."
        $Html = @"
<!DOCTYPE html>
<html lang="da">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>DR Lyd - Recycled</title>
        <link rel="icon" href="assets/icon-recycle.svg">
        <link rel="stylesheet" href="https://www.dr.dk/global/publik.css">
        <link rel="stylesheet" href="stylesheet.css">
    </head>
    <body>
        <header>
            <a href="https://www.dr.dk/lyd" target="_blank"><img class="logo drlyd" src="assets/icon-logo-drlyd.svg" alt="DR Lyd - Recycled"/></a>
            <div class="title">
                <h1>DR Lyd</h1>
                <h2>Recycled</h2>
            </div>
            <a href="https://github.com/briped/briped.github.io" target="_blank"><img class="logo github" src="assets/icon-logo-github-light.svg" alt="Github"/></a>
        </header>
        <main>
            <div class="grid">
"@
    }
    process {
        $ImageAssets = $Podcast.imageAssets | Where-Object { $_.ratio -eq '1:1' }
        if ($ImageAssets.target -contains 'Podcast') {
            $ImageAssets | Where-Object { $_.target -eq 'Podcast' }
        }
        else {
            $ImageAssets | Where-Object { $_.target -eq 'Default' }
        }
        $ImageUri = $ImageAsset.uri.AbsoluteUri.Replace($ImageAsset.uri.Query, $ImageAsset.uri.Query.Replace('&', '&#x26;'))
        if (Test-Path -PathType Leaf -Path (Join-Path -Path $PodPath -ChildPath 'cover' -AdditionalChildPath "$($Podcast.sSlug).jpg")) {
            $ImageUri = "$($PodBase.Scheme)://$($PodBase.Host)/$((([uri]"$($PodBase.AbsoluteUri)/cover/$($Podcast.sSlug).jpg").AbsolutePath -split '/' | Where-Object { $_ }) -join '/')"
        }
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): ImageUri: $($ImageUri)"
        $Html += @"

                <div class="podcast" title="$($Podcast.title) - $($Podcast.numberOfEpisodes) episoder">
                    <div class="cover">
                        <a href="$($Podcast.rssUri)"><img src="$($ImageUri)" alt="$($Podcast.title)"></a>
                        <a href="$($Podcast.rssUri)"><div class="icon-rss"></div></a>
                        <a href="$($Podcast.presentationUrl)" target="_blank"><div class="icon-logo-drlyd"></div></a>
                        <div class="episodes">$($Podcast.numberOfEpisodes)</div>
                    </div>
                    <div class="name">$($Podcast.title)</div>
                </div>
"@
    }
    end {
        $Html += @"

            </div>
        </main>
        <footer>
            <p>Last updated: $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')</p>
        </footer>
    </body>
</html>
"@
        $Html
    }
}
function Set-ImageAssetUri {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[Alias('p')]
		[object]
		$Podcast
		,
		[Parameter()]
		[Alias('w')]
		[int]
		$Width = 720
	)
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Adding image URIs to podcast '$($Podcast.title)'."
	$AssetUri = [uri]'https://asset.dr.dk/imagescaler/?protocol=https&server=api.dr.dk&file='
	$AssetFilePath = '/radio/v2/images/raw/'
	foreach ($a in $Podcast.imageAssets) {
		$r = $a.ratio -split ':'
		$Height = [Math]::Round($Width / ($r[0] / $r[1]))
		[string]$Uri  = $AssetUri.AbsoluteUri
		$Uri += [uri]::EscapeDataString($AssetFilePath + $a.id)
		$Uri += "&scaleAfter=crop&quality=70&w=$($Width)&h=$($Height)"
		[uri]$Uri = $Uri
		if (!$a.uri) {
			$a | Add-Member -NotePropertyName 'uri' -NotePropertyValue $Uri
		}
		else {
			$a.uri = $Uri
		}
	}
}
function Add-Watermark {
    param (
        # Path to image file that should be watermarked.
        [Parameter(Mandatory = $true)]
        [Alias('ip', 'Image', 'Img')]
        [System.IO.FileInfo]
        $ImagePath
        ,
        # Path to where the watermarked image should be saved.
        [Parameter(Mandatory = $true)]
        [Alias('op', 'Output', 'Out')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputPath
        ,
        # Path to the watermark.
        [Parameter()]
        [Alias('wp', 'Watermark')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $WatermarkPath
        ,
        # X starting position of the watermark. Defaults to 0.
        [Parameter()]
        [Alias('x')]
        [int]
        $PositionX = 0
        ,
        # Y starting position of the watermark. Defaults to 0.
        [Parameter()]
        [Alias('y')]
        [int]
        $PositionY = 10
        ,
        # Width of the watermark. Can be specified in pixels or percentage. If no unit is found the number is read as pixels. Defaults to watermark width.
        [Parameter()]
        [ValidatePattern('[1-9]+(px|%)?')]
        [Alias('w')]
        [string]
        $Width = '180px'
        ,
        # Height of the watermark. Can be specified in pixels or percentage. If no unit is found the number is read as pixels. Defaults to watermark height.
        [Parameter()]
        [ValidatePattern('[1-9]+(px|%)?')]
        [Alias('h')]
        [string]
        $Height
        ,
        # Opacity of the watermark in percent.
        [Parameter()]
        [ValidateRange(0, 100)]
        [Alias('o')]
        [int]
        $Opacity = 70
        ,
        # X starting position of area to be excluded in the brightness calculation. Defaults to 0.
        [Parameter()]
        [Alias('ex')]
        [int]
        $ExcludeX = 45
        ,
        # Y starting position of area to be excluded in the brightness calculation. Defaults to 0.
        [Parameter()]
        [Alias('ey')]
        [int]
        $ExcludeY = 45
        ,
        # Width of area to be excluded in the brightness calculation. Defaults to image width.
        [Parameter()]
        [Alias('ew')]
        [int]
        $ExcludeWidth = 90
        ,
        # Height of area to be excluded in the brightness calculation. Defaults to image height.
        [Parameter()]
        [Alias('eh')]
        [int]
        $ExcludeHeight = 90
    )

    # Load the necessary .NET assemblies
    Add-Type -AssemblyName System.Drawing
    # Load the image and the watermark
    $Image = [System.Drawing.Image]::FromFile($ImagePath.FullName)
    $Watermark = [System.Drawing.Image]::FromFile($WatermarkPath.FullName)

    # Calculate the aspect ratio of the watermark
    $Ratio = $Watermark.Width / $Watermark.Height

    # Parse the requested dimensions of the watermark.
    if ($Height -match '(?<n>\d+)(?<u>px|%)?') {
        [int]$Height = if ($Matches.u -eq '%') { [int](($Image.Height / 100) * $Matches.n) } else { [int]$Matches.n }
    }
    if ($Width -match '(?<n>\d+)(?<u>px|%)?') {
        [int]$Width = if ($Matches.u -eq '%') { [int](($Image.Width / 100) * $Matches.n) } else { [int]$Matches.n }
    }

    # Calculate the dimensions of the watermark
    if (!$Width -and !$Height) {
        [int]$Width = $Watermark.Width
        [int]$Height = $Watermark.Height
    }
    elseif (!$Height) {
        [int]$Height = [int]($Width / $Ratio)
    }
    elseif (!$Width) {
        [int]$Width = [int]($Height * $Ratio)
    }

    # Create a graphics object from the image
    $Graphics = [System.Drawing.Graphics]::FromImage($Image)

    # Calculate the brightness exclusion area.
    # Set to 0 if null, otherwise the actual value.
    $ExcludeX = [int]$ExcludeX
    $ExcludeY = [int]$ExcludeY
    # Set the missing exclude dimension to image dimension.
    if ($ExcludeWidth -and !$ExcludeHeight) {
        $ExcludeHeight = $Image.Height
    }
    elseif ($ExcludeHeight -and !$ExcludeWidth) {
        $ExcludeWidth = $Image.Width
    }

    $Brightness = 0.0
    $PixelCount = 0
    for ($i = $PositionX; $i -lt $PositionX + $Width; $i++) {
        for ($j = $PositionY; $j -lt $PositionY + $Height; $j++) {
            if ($i -lt $Image.Width -and $j -lt $Image.Height) {
                # Skip pixel from brightness check.
                if (!$ExcludeWidth -and !$ExcludeHeight) { continue }
                if ($i -ge $ExcludeX -and $i -lt ($ExcludeX + $ExcludeWidth) -and 
                    $j -ge $ExcludeY -and $j -lt ($ExcludeY + $ExcludeHeight)) { Continue }

                $Pixel = $Image.GetPixel($i, $j)
                $Brightness += ($Pixel.R * 0.299 + $Pixel.G * 0.587 + $Pixel.B * 0.114) / 255
                $PixelCount++
            }
        }
    }
    if ($PixelCount -gt 0) {
        $Brightness /= $PixelCount
    }

    $AdjustedWatermark = [System.Drawing.Bitmap]::new($Width, $Height)
    $GraphicsWatermark = [System.Drawing.Graphics]::FromImage($AdjustedWatermark)
    $GraphicsWatermark.DrawImage($Watermark, [System.Drawing.Rectangle]::new(0, 0, $Width, $Height))
    for ($i = 0; $i -lt $Width; $i++) {
        for ($j = 0; $j -lt $Height; $j++) {
            $Pixel = $AdjustedWatermark.GetPixel($i, $j)
            $Alpha = $Pixel.A
            if ($Pixel.R -eq 0 -and $Pixel.G -eq 0 -and $Pixel.B -eq 0) {
                if ($Brightness -lt 0.5) {
                    $NewColor = [System.Drawing.Color]::FromArgb($Alpha, 255, 255, 255) # White on dark
                }
                else {
                    $NewColor = [System.Drawing.Color]::FromArgb($Alpha, 0, 0, 0) # Black on bright
                }
            }
            else {
                $NewColor = [System.Drawing.Color]::FromArgb($Alpha, $Pixel.R, $Pixel.G, $Pixel.B)
            }
            $AdjustedWatermark.SetPixel($i, $j, $NewColor)
        }
    }

    [float]$Opacity = if ($Opacity -gt 0) { $Opacity / 100 } else { $Opacity }
    $ColorMatrix = New-Object System.Drawing.Imaging.ColorMatrix
    $ColorMatrix.Matrix33 = $Opacity

    $ImageAttributes = New-Object System.Drawing.Imaging.ImageAttributes
    $ImageAttributes.SetColorMatrix($ColorMatrix, [System.Drawing.Imaging.ColorMatrixFlag]::Default, [System.Drawing.Imaging.ColorAdjustType]::Bitmap)

    $Graphics.DrawImage(
        $AdjustedWatermark,
        [System.Drawing.Rectangle]::new($PositionX, $PositionY, $Width, $Height),
        0,
        0,
        $AdjustedWatermark.Width,
        $AdjustedWatermark.Height,
        [System.Drawing.GraphicsUnit]::Pixel,
        $ImageAttributes
    )

    $Image.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

    $Graphics.Dispose()
    $Image.Dispose()
    $Watermark.Dispose()
    $GraphicsWatermark.Dispose()
    $AdjustedWatermark.Dispose()
}
