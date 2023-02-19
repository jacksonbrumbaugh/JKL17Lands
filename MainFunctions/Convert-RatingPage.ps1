<#
.SYNOPSIS
Converts a 17Lands card rating page into an array of PSCustomObject card ratings

.NOTES
Created by Jackson Brumbaugh on 2023.02.19
Version Code: 2023Feb19-B
#>
function Convert-RatingPage {
  [CmdletBinding()]
  param (
    [Parameter(
      Mandatory
    )]
    [datetime]
    $Date
  ) # End block:param

  process {
    $PageArray = Get-RatingPage $Date

    $CardRatingArray = @()
    foreach ( $ThisPage in $PageArray ) {
      $ThisPageContent = if ( $ThisPage.Content ) {
        $ThisPage.Content
      } else {
        $ThisPage
      }

      # As of 2023.02.19, this start line looks like "Name _ Color _ Rarity _ # _ GIH" where " _ " indicates a tab
      $StartConvertingLine = $ThisPageContent -match "^Name"

      if ( $StartConvertingLine.Count -eq 0 ) {
        Write-Warning "This card rating page does not have a line that begins with Name. This page has been skipped. "
      }

      if ( $StartConvertingLine.Count -gt 1 ) {
        Write-Warning "This card rating page has more than 1 line that begins with Name. This page has been skipped. "
        continue
      }

      Write-Verbose "Scanning page content for card ratings"
      $isConverting = $false
      $LineIndex = -1
      foreach ( $ThisLine in $ThisPageContent ) {
        $LineIndex++

        if ( $ThisLine -eq $StartConvertingLine ) {
          Write-Verbose "Start converting card ratings"
          $isConverting = $true
        }

        if ( -not $isConverting ) {
          continue
        }

        # Using the empty lines after the card names as the card line group indicator
        if ( -not [string]::IsNullOrEmpty($ThisLine) ) {
          continue
        }

        $CardName = $ThisPageContent[($LineIndex - 1)]

        $StatLine = $ThisPageContent[($LineIndex + 1)]

        <# As of 2023.02.19
        Some cards are formatted with 4 lines
        e.g.
        Atraxa, Grand Unifier

        WUBG	M	1089	
        61.3%

        while others with 3 lines
        e.g.
        Blue Sun's Twilight

        U	R	5738	60.8%
        #>
        if ( $StatLine -notmatch "%" ) {
          $StatLine += $ThisPageContent[($LineIndex + 2)]
        }

        $CardStatArray = $StatLine.split()

        $SkipThisCard = $false
        $Color, $Rarity, $Played, $GIH = switch ( $CardStatArray.Count ) {
          4 { $CardStatArray }
          Default { $SkipThisCard = $true}
        }

        if ( $Rarity -notin ("C", "R", "U", "M") ) {
          $SkipThisCard = $true
        }

        if ( $SkipThisCard ) {
          Write-Verbose "Skipping $CardName"
          continue
        }

        Write-Verbose "Converting ratings for $CardName"
        $CardRatingArray += [PSCustomObject]@{
          Name    = $CardName
          Color   = $Color
          Rarity  = $Rarity
          Played  = $Played -as [int]
          WinRate = ($GIH -replace "%", "") -as [single]
        }

      } # End block:foreach ThisLine

      Write-Output $CardRatingArray

    } # End block:foreach ThisPage

  } # End block:process

} # End function
