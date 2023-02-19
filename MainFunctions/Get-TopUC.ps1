<#
.SYNOPSIS
Returns the top common & uncommon cards from a card ratings page

.NOTES
Created by Jackson Brumbaugh on 2023.02.19
Version Code: 2023Feb19-B
#>
function Get-TopUC {
  [CmdletBinding()]
  param (
    [Parameter(
      Mandatory
    )]
    [datetime]
    $Date,

    [switch]
    $Alphabetical,

    [switch]
    $Grid

  ) # End block:param

  process {
    $CardRatingArray = Convert-RatingPage $Date

    $FoundColorHash = @{
      W = $false
      U = $false
      B = $false
      R = $false
      G = $false
    }

    $FoundColorCount = 0

    $Rank = 1
    $TopUCArray = foreach ( $ThisCard in $CardRatingArray ) {
      if ( $ThisCard.Rarity -notin ("C", "U") ) {
        continue
      }

      foreach ( $ThisColor in ("W", "U", "B", "R", "G") ) {
        if ( $ThisCard.Color -eq $ThisColor -and -not $FoundColorHash.$ThisColor ) {
          $FoundColorHash.$ThisColor = $true
          $FoundColorCount++
        }
      }

      $ThisCard | Add-Member -MemberType NoteProperty -Name Rank -Value ($Rank++)

      $ThisCard

      if ( $FoundColorCount -eq 5 ) {
        break
      }

    } # End block:foreach ThisCard

    if ( $Alphabetical ) {
      $TopUCArray = $TopUCArray | Sort-Object Name
    }

    if ( $Grid ) {
      $TopUCArray | Out-GridView
    }

    Write-Output $TopUCArray

  } # End block:process

} # End function