<#
.SYNOPSIS
PowerShell module to work in tandem with 17Lands.com data

.NOTES
Create by Jackson Brumbaugh on 2023.02.19
#>

$ModuleRootDir = $PSScriptRoot
$ModuleName = Split-Path $ModuleRootDir -Leaf

$NoExportKeywordArray = @(
  "Help",
  "Support"
)

foreach ( $ThisDir in (Get-ChildItem $ModuleRootDir -Directory) ) {
  $ThisDirItem = Get-Item $ModuleRootDir\$ThisDir

  $FunctionScriptArray = Get-ChildItem -Path $ThisDirItem -Include "*.ps1" -Recurse

  foreach ( $ThisScript in $FunctionScriptArray ) {
    $ThisScriptItem = Get-Item $ThisScript
    $ThisScriptFullName = $ThisScriptItem.FullName

    # Dot-Sourcing; loads the function as part of the module
    . $ThisScriptFullName

    $DirName = Split-Path (Split-Path $ThisScriptFullName) -Leaf
    $FunctionName = (Split-Path $ThisScriptFullName -Leaf).replace( '.ps1', '' )

    $doExport = $true
    foreach ( $ThisKeyword in $NoExportKeywordArray ) {
      if ( $DirName -match $ThisKeyword ) {
        $doExport = $false
      }
    }

    if ( $doExport ) {
      # Lets users use / see the function
      Export-ModuleMember $FunctionName
    }

  } # End block:foreach Script in FunctionScriptArray

} # End block:foreach Dir in ChildDIrs

$Aliases = (Get-Alias).Where{ $_.Source -eq $ModuleName }
$AliasNames = $Aliases.Name -replace "(.*) ->.*","`$1"
foreach ( $Alias in $AliasNames ) {
  # Lets users use / see the alias
  Export-ModuleMember -Alias $Alias
}
