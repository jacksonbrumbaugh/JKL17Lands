<#
.SYNOPSIS
Returns the content of a card rating page

.NOTES
Created by Jackson Brumbaugh on 2023.02.19
Version Code: 2023Feb19-B
#>
function Get-RatingPage {
  param (
    [Parameter(
      Mandatory
    )]
    [datetime]
    $Date
  ) # End block:param

  begin {
    Write-Verbose "Getting the locatoin of the Card Rating Page folder. "
    $RatingPageDirLocation = Get-RatingPageDirLocation

    $ErrorDetails = @{
      ErrorAction = "Stop"
    }
  } # End block:begin

  process {
    $DisplayDate = $Date.ToString( "MMM dd, yyyy" )
    $SearchDate = $Date.ToString( "*yyyy*MM*dd*" )

    $PageItem = Get-Item $RatingPageDirLocation\$SearchDate

    if ( [string]::IsNullOrEmpty($PageItem) ) {
      $ErrorDetails.Message = "Failed to find a card rating page from $DisplayDate. "
      Write-Error @ErrorDetails
    }

    if ( $PageItem.Count -gt 1 ) {
      $ErrorDetails.Message = "Found multiple card rating pages from $DisplayDate. "
      Write-Error @ErrorDetails
    }

    Write-Verbose "Getting content from page $($PageItem.Name). "
    $Page = [PSCustomObject]@{
      Name     = $PageItem.Name
      FullName = $PageItem.FullName
      Content  = Get-Content $PageItem
    }

    Write-Output $Page

  } # End block:process

} # End function
