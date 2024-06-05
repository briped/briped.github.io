$global:ApiKey = Get-Content -TotalCount 1 -Path (Join-Path -Path $PSScriptRoot -ChildPath '.apiKey')
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
        Write-Verbose -Message "Invoke-RestMethod @$($Splatter | ConvertTo-Json -Compress)"
        $Response = Invoke-RestMethod @Splatter
        
        foreach ($Podcast in $Response.items) {
            $Sslug = $Podcast.slug.Replace("-$($Podcast.productionNumber)", '')
            $RssPath = ([uri]"$($PodBase.AbsoluteUri)/$($Sslug).xml").LocalPath -split '/' | Where-Object { $_ }
            $RssUri = [uri]"$($PodBase.Scheme)://$($PodBase.Host)/$($RssPath -join '/')"
    
            $ImageAsset = $Podcast.imageAssets | Where-Object target -eq 'podcast'
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
            Write-Verbose -Message "Adding property: sSlug = $($Sslug))"
            $Podcast | Add-Member -NotePropertyName sSlug -NotePropertyValue $Sslug
            Write-Verbose -Message "Adding property: imageUri = $($ImageUri))"
            $Podcast | Add-Member -NotePropertyName imageUri -NotePropertyValue $ImageUri
            Write-Verbose -Message "Adding property: rssUri = $($RssUri))"
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
        Write-Verbose -Message "Invoke-RestMethod @$($Splatter | ConvertTo-Json -Compress)"
        $Podcast = Invoke-RestMethod @Splatter

        $Sslug = $Podcast.slug.Replace("-$($Podcast.productionNumber)", '')
        $RssPath = ([uri]"$($PodBase.AbsoluteUri)/$($Sslug).xml").LocalPath -split '/' | Where-Object { $_ }
        $RssUri = [uri]"$($PodBase.Scheme)://$($PodBase.Host)/$($RssPath -join '/')"

        $ImageAsset = $Podcast.imageAssets | Where-Object target -eq 'podcast'
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
        Write-Verbose -Message "Adding property: sSlug = $($Sslug))"
        $Podcast | Add-Member -NotePropertyName sSlug -NotePropertyValue $Sslug
        Write-Verbose -Message "Adding property: imageUri = $($ImageUri))"
        $Podcast | Add-Member -NotePropertyName imageUri -NotePropertyValue $ImageUri
        Write-Verbose -Message "Adding property: rssUri = $($RssUri))"
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
        Write-Verbose -Message "Invoke-RestMethod @$($Splatter | ConvertTo-Json -Compress)"
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
    if (!($ImageUri = Resolve-Path -Path (Join-Path -Path $PodPath -ChildPath "$($Podcast.sSlug).jpg") -ErrorAction SilentlyContinue)) {
        $ImageUri = $Podcast.imageUri.AbsoluteUri.Replace($Podcast.imageUri.Query, $Podcast.imageUri.Query.Replace('&', '&#x26;'))
    }
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
        $AudioAsset = $Episode.audioAssets | Where-Object { $_.format -eq 'mp4' -and $_.bitrate -eq 64 }
        $Rss += @"
        <item>
            <guid isPermaLink="false">$($Episode.productionNumber)</guid>
            <link>$($Episode.presentationUrl)</link>
            <title>$(repl($Episode.title))</title>
            <description>$(repl($Episode.description))</description>
            <pubDate>$($Episode.publishTime.ToString("ddd, dd MMM yyyy HH:mm:ss zzz"))</pubDate>
            <itunes:explicit>$($Episode.explicitContent)</itunes:explicit>
            <itunes:author>DR</itunes:author>
            <itunes:duration>$(New-TimeSpan -Milliseconds $Episode.durationMilliseconds).ToString('hh\:mm\:ss')</itunes:duration>
            <media:restriction type="country" relationship="allow">dk</media:restriction>
            <enclosure url="$($AudioAsset.url).$($AudioAsset.format)" 
                type="audio/mpeg" 
                length="$($AudioAsset.fileSize)" />
        </item>
"@
    }
    $Rss += @"
    </channel>
</rss>
"@
    $Rss
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
        Write-Verbose -Message $Podcast.Count
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
        $Html += @"

            <div class="grid-item" title="$($Podcast.title) - $($Podcast.numberOfEpisodes) episoder">
                <div class="podcast-container">
                    <a href="$($Podcast.rssUri)"><img src="$($Podcast.imageUri)" alt="$($Podcast.title)"></a>
                    <a href="feed://$($Podcast.rssUri.Host)$($Podcast.rssUri.PathAndQuery)"><div class="icon-rss"></div></a>
                    <a href="pcast://$($Podcast.rssUri.Host)$($Podcast.rssUri.PathAndQuery)"><div class="icon-app-pcast"></div></a>
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
function Add-Watermark {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]
        $ImagePath
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputPath
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $WatermarkPath
        ,
        # X position of watermark
        [Parameter()]
        [Alias('x')]
        [int]
        $PositionX
        ,
        # Y position of watermark
        [Parameter()]
        [Alias('y')]
        [int]
        $PositionY
        ,
        # Height of watermark
        [Parameter()]
        [ValidatePattern('[1-9]+(px|%)?')]
        [Alias('h')]
        [string]
        $Height
        ,
        # Width of watermark
        [Parameter()]
        [ValidatePattern('[1-9]+(px|%)?')]
        [Alias('w')]
        [string]
        $Width
        ,
        # Opacity of watermark
        [Parameter()]
        [ValidateRange(0, 100)]
        [Alias('o')]
        [int]
        $Opacity
    )
    Add-Type -AssemblyName System.Drawing
    $Image  = [System.Drawing.Image]::FromFile($ImagePath)
    $Watermark = [System.Drawing.Image]::FromFile($WatermarkPath)
    $Ratio = $Watermark.Width / $Watermark.Height

    if ($Height -match '(?<n>\d+)(?<u>px|%)?') {
        $Height = if ($Matches.u -eq '%') { [int](($Image.Height / 100) * $Matches.n) } else { [int]$Matches.n }
    }
    if ($Width -match '(?<n>\d+)(?<u>px|%)?') {
        $Width = if ($Matches.u -eq '%') { [int](($Image.Width / 100) * $Matches.n) } else { [int]$Matches.n }
    }
    if (!$Width -and !$Height) {
        $Width = $Watermark.Width
        $Height = $Watermark.Height
    }
    elseif (!$Height) {
        $Height = [int]($Width / $Ratio)
    }
    elseif (!$Width) {
        $Width = [int]($Height * $Ratio)
    }

    $Graphics = [System.Drawing.Graphics]::FromImage($Image)
    if ($Opacity) {
        [float]$Opacity = if ($Opacity -gt 0) { $Opacity / 100 } else { $Opacity }
        $ColorMatrix = New-Object System.Drawing.Imaging.ColorMatrix
        $ColorMatrix.Matrix33 = $Opacity
        $ImageAttributes = New-Object System.Drawing.Imaging.ImageAttributes
        $ImageAttributes.SetColorMatrix($ColorMatrix, [System.Drawing.Imaging.ColorMatrixFlag]::Default, [System.Drawing.Imaging.ColorAdjustType]::Bitmap)
    
        $Graphics.DrawImage(
            $Watermark,
            [System.Drawing.Rectangle]::new($PositionX, $PositionY, $Width, $Height),
            0,
            0,
            $Watermark.Width,
            $Watermark.Height,
            [System.Drawing.GraphicsUnit]::Pixel,
            $ImageAttributes
        )
    }
    else {
        $Graphics.DrawImage($Watermark, $PositionX, $PositionY, $Width, $Height)
    }
    $Image.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $Graphics.Dispose()
    $Image.Dispose()
    $Watermark.Dispose()
}
