$global:ApiBase = [uri]'https://api.dr.dk/radio/v2'
$global:ImgBase = [uri]'https://asset.dr.dk/imagescaler/'
$global:RssBase = [uri]'https://briped.github.io/podcast/'
$global:Headers = @{
    'x-apikey' = '6Wkh8s98Afx1ZAaTT4FuWODTmvWGDPpR'
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
        $Response.items
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
		$RssPath = ([uri]"$($RssBase.AbsoluteUri)/$($Sslug).xml").LocalPath -split '/' | Where-Object { $_ }
		$RssUri = [uri]"$($RssBase.Scheme)://$($RssBase.Host)/$($RssPath -join '/')"

        $ImageAsset = $Podcast.imageAssets | Where-Object target -eq 'Podcast'
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
        $UriBuilder.Query = $QueryCollection.ToString().Replace('&', '&#x26;')
        $ImageUri = $UriBuilder.Uri.AbsoluteUri
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
        <title>$($Podcast.title.Replace('&', '&#x26;').Replace('<', '&#x3C;').Replace('<', '&#x3E;'))</title>
        <link>$($Podcast.presentationUrl)</link>
        <description>$($Podcast.description.Replace('&', '&#x26;').Replace('<', '&#x3C;').Replace('<', '&#x3E;'))</description>
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
            <url>$($Podcast.imageUri)</url>
            <title>$($Podcast.title.Replace('&', '&#x26;').Replace('<', '&#x3C;').Replace('<', '&#x3E;'))</title>
            <link>$($Podcast.presentationUrl)</link>
        </image>
        <itunes:image href="$($Podcast.imageUri)" />
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
            <title>$($Episode.title.Replace('&', '&#x26;').Replace('<', '&#x3C;').Replace('<', '&#x3E;'))</title>
            <description>$($Episode.description.Replace('&', '&#x26;').Replace('<', '&#x3C;').Replace('<', '&#x3E;'))</description>
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
    <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Podcasts</title>
            <style type="text/css">
            body {
                margin: 0;
                font-family: Arial, sans-serif;
            }
            .grid-container {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                gap: 10px;
                padding: 10px;
            }
            .grid-item {
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            .podcast-container {
                width: 100%;
                padding-top: 100%;
                position: relative;
            }
            .podcast-container img {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            .podcast-name {
                margin-top: 5px;
                text-align: center;
                font-size: 14px;
                color: #333;
            }
            .podcast-episodes {
                position: absolute;
                bottom: 5px;
                right: 5px;
                font-size: 12px;
                color: #fff;
                background-color: rgba(0, 0, 0, 0.5);
                padding: 2px 5px;
                border-radius: 3px;
            }
            </style>
        </head>
        <body>
            <div class="grid-container">
"@
    }
    process {
        $Html += @"

                <div class="grid-item">
                    <div class="podcast-container">
                        <a href="$($Podcast.rssUri)"><img src="$($Podcast.imageUri)" alt="$($Podcast.title)"></a>
                        <div class="podcast-episodes">$($Podcast.numberOfEpisodes) episoder</div>
                    </div>
                    <div class="podcast-name">$($Podcast.title)</div>
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
