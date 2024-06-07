function RecycleCover {
    [CmdletBinding()]
    param (
        # Path to image file that should be watermarked.
        [Parameter(Mandatory = $true)]
        [Alias('i', 'Image', 'Img')]
        [System.IO.FileInfo]
        $ImagePath
        ,
        # Path to where the watermarked image should be saved.
        [Parameter(Mandatory = $true)]
        [Alias('o', 'Output', 'Out')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputPath
        ,
        # Path to the watermark.
        [Parameter()]
        [Alias('w', 'Watermark')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $WatermarkPath
    )

    # Load the necessary .NET assemblies
    Add-Type -AssemblyName System.Drawing
    # Load the image and the watermark
    $Image = [System.Drawing.Image]::FromFile($ImagePath.FullName)
    $ImageRatio = $Image.Width / $Image.Height
    Write-Verbose -Message "File: '$($ImagePath.Name)'. Width: $($Image.Width)px. Height: $($Image.Height)px. Ratio: '$($ImageRatio)'."
    $Watermark = [System.Drawing.Image]::FromFile($WatermarkPath.FullName)
    $WatermarkRatio = $Watermark.Width / $Watermark.Height
    Write-Verbose -Message "File: '$($WatermarkPath.Name)'. Width: $($Watermark.Width)px. Height: $($Watermark.Height)px. Ratio: '$($WatermarkRatio)'."

    $Width = [int]$Image.Width
    $Height = [int][Math]::Round($Width / $WatermarkRatio)
    $PositionX = [int]0
    $PositionY = [int][Math]::Round(($Image.Height - $Height))
    Write-Verbose -Message "Watermark. X: $($PositionX). Y: $($PositionY). Width: $($Width)px. Height: $($Height)px."
    $Opacity = [float]0.7
    $Text = 'recycled'
    $FontName = 'Verdana'
    $FontSize = 72

    # Create a graphics object from the image
    $Graphics = [System.Drawing.Graphics]::FromImage($Image)

    $Brightness = 0.0
    $PixelCount = 0
    for ($x = $PositionX; $x -lt $PositionX + $Width; $x++) {
        for ($y = $PositionY; $y -lt $PositionY + $Height; $y++) {
            if ($x -lt $Image.Width -and $y -lt $Image.Height) {
                $Pixel = $Image.GetPixel($x, $y)
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
    for ($x = 0; $x -lt $Width; $x++) {
        for ($y = 0; $y -lt $Height; $y++) {
            $Pixel = $AdjustedWatermark.GetPixel($x, $y)
            $Alpha = $Pixel.A
            if ($Pixel.R -eq 0 -and $Pixel.G -eq 0 -and $Pixel.B -eq 0) {
                if ($Brightness -lt 0.5) {
                    $Color = [System.Drawing.Color]::FromArgb($Alpha, 255, 255, 255) # White on dark
                }
                else {
                    $Color = [System.Drawing.Color]::FromArgb($Alpha, 0, 0, 0) # Black on bright
                }
            }
            else {
                $Color = [System.Drawing.Color]::FromArgb($Alpha, $Pixel.R, $Pixel.G, $Pixel.B)
            }
            $AdjustedWatermark.SetPixel($x, $y, $Color)
        }
    }

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

    $TextColor = if ($Brightness -lt 0.5) { 'White' } else { 'Black' }
    Write-Verbose -Message "$FontName and $FontSize"
    $Font = [System.Drawing.Font]::new($FontName, $FontSize, [System.Drawing.FontStyle]::Bold)
    $PointF = [System.Drawing.PointF]::new(20, $Height - 80)
    $Color = [System.Drawing.Color]::FromArgb([int]($Opacity * 255), [System.Drawing.Color]::FromName($TextColor))
    $SolidBrush = [System.Drawing.SolidBrush]::new($Color)
    $Graphics.DrawString($Text, $Font, $SolidBrush, $PointF)
    $SolidBrush.Dispose()

    $Image.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $Graphics.Dispose()
    $Image.Dispose()
    $Watermark.Dispose()
    $GraphicsWatermark.Dispose()
    $AdjustedWatermark.Dispose()
}
$SourcePath = [System.IO.FileInfo](Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent -ChildPath 'podcast' -AdditionalChildPath '.source')
$Watermark = Join-Path -Path $SourcePath -ChildPath 'assets' -AdditionalChildPath 'icon-recycle.png'
Get-ChildItem -Path $PodSourcePathPath -Filter '*_1-1_podcast_*.jpeg' | ForEach-Object {
    RecycleCover -WatermarkPath $Watermark -ImagePath $_ -OutputPath "$(($_.Name -split '_1-1_podcast_')[0]).jpg"
}
