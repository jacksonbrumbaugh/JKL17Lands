<#
.SYNOPSIS
Returns the full name path of the folder of 17Lands card rating pages

.NOTES
Created by Jackson Brumbaugh on 2023.02.19
Version Code: 2023Feb19-A
#>
function Get-RatingPageDirLocation {
  $LocationKeyword = "CardRating"
  $LocationItem = Get-Item $ModuleRootDir\*$LocationKeyword*

  $ErrorDetails = @{
    ErrorAction = "Stop"
  }
  if ( [string]::IsNullOrEmpty($LocationItem) ) {
    $ErrorDetails.Message = "Failed to find the folder for Card Rating Pages. "
    Write-Error @ErrorDetails
  }

  if ( $LocationItem.Count -gt 1 ) {
    $ErrorDetails.Message = "Found more than 1 *{0}* folder in the module {1}" -f $LocationKeyword, $ModuleName
    Write-Error @ErrorDetails
  }

  Write-Output $LocationItem.FullName

} # End function
