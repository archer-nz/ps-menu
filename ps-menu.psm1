<#
.PARAMETER  MenuItems
Array of objects or strings containing menu items. Must contain at least one item.
Must not contain $null.

.PARAMETER  ReturnIndex
Returns index of selected menu item

.PARAMETER  MultiSelect
Allow the user to select multiple items instead of a single item.

.EXAMPLE
Show-Menu @("option 1", "option 2", "option 3") -MultiSelect
#>

function DrawMenu {
    param ($menuItems, $menuPosition, $Multiselect, $currentSelection)
    $l = $menuItems.length
    for ($i = 0; $i -le $l;$i++) {
		if ($null -ne $menuItems[$i]){
			$item = $menuItems[$i]
			if ($Multiselect)
			{
				if ($currentSelection -contains $i){
					$item = '[x] ' + $item
				}
				else {
					$item = '[ ] ' + $item
				}
			}
			if ($i -eq $menuPosition) {
				Write-Host "> $($item)" -ForegroundColor Green
			} else {
				Write-Host "  $($item)"
			}
		}
    }
}

function Switch-Selection {
	param ($cursorPosition, [array]$currentSelection)
	if ($currentSelection -contains $cursorPosition){ 
		$result = $currentSelection | Where-Object {$_ -ne $cursorPosition}
	}
	else {
		$currentSelection += $cursorPosition
		$result = $currentSelection
	}
	$result
}

function Show-Menu {
    param ([array]$menuItems, [switch]$ReturnIndex=$false, [switch]$Multiselect)
    $vkeycode = 0
    $cursorPosition = 0
    $currentSelection = @()
    if ($menuItems.Length -gt 0)
	{
		try {
			$startPos = [System.Console]::CursorTop #Fix for ESC to quit the menu misplaces the next prompt | https://github.com/chrisseroka/ps-menu/issues/13#issuecomment-1555276093
			[console]::CursorVisible=$false #prevents cursor flickering
			DrawMenu $menuItems $cursorPosition $Multiselect $currentSelection
			While ($vkeycode -ne 13 -and $vkeycode -ne 27) {
				$press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
				$vkeycode = $press.virtualkeycode
				If ($vkeycode -eq 38 -or $press.Character -eq 'k') {$cursorPosition--}
				If ($vkeycode -eq 40 -or $press.Character -eq 'j') {$cursorPosition++}
				If ($vkeycode -eq 36) { $cursorPosition = 0 }
				If ($vkeycode -eq 35) { $cursorPosition = $menuItems.length - 1 }
				If ($press.Character -eq ' ') { $currentSelection = Switch-Selection $cursorPosition $currentSelection }
				if ($cursorPosition -lt 0) {$cursorPosition = 0}
				If ($vkeycode -eq 27) {$cursorPosition = $null }
				if ($cursorPosition -ge $menuItems.length) {$cursorPosition = $menuItems.length -1}
				if ($vkeycode -ne 27)
				{
					$startPos = [System.Console]::CursorTop - $menuItems.Length
					[System.Console]::SetCursorPosition(0, $startPos)
					DrawMenu $menuItems $cursorPosition $Multiselect $currentSelection
				}
			}
		}
		finally {
			[System.Console]::SetCursorPosition(0, $startPos + $menuItems.Length)
			[console]::CursorVisible = $true
		}
	}
	else {
		$cursorPosition = $null
	}

    if ($ReturnIndex -eq $false -and $null -ne $cursorPosition)
	{
		if ($Multiselect){
			return $menuItems[$currentSelection]
		}
		else {
			return $menuItems[$cursorPosition]
		}
	}
	else 
	{
		if ($Multiselect){
			return $currentSelection
		}
		else {
			return $cursorPosition
		}
	}
}

