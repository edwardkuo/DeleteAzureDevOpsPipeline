$AzureDevOpspersonalToken = "輸入PAT"
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpspersonalToken)"))
$HTTPHearder = @{authorization = "Basic $token" }

$organization = "組織名稱"
$project = "專案名稱"

$url = "https://dev.azure.com/$organization/$project/_apis/build/definitions?api-version=6.0-preview.7"
$builddefinitions = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers $HTTPHearder

#取得異常Pipeline的ID序號
$buildID = $builddefinitions.value | Where-Object { $_.name -eq "輸入Pipeline Name" } | Select-Object -ExpandProperty  id

$url = "https://dev.azure.com/$organization/$project/_apis/build/builds?definitions=" + $buildID + "&api-version=6.0-preview.5"
$builds = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers $HTTPHearder
$builds.value | Sort-Object id|ForEach-Object {
    #report on retain status
    Write-Host " BuildId" $_.id "- retainedByRelease:" $_.retainedByRelease
    $url = "https://dev.azure.com/$organization/$project/_apis/build/builds/"+$_.id+"?api-version=6.0-preview.5"
    Invoke-RestMethod -Uri $url -Method Patch  -ContentType "application/json" -Headers $HTTPHearder -Body (ConvertTo-Json @{"retainedByRelease"='False'})
}    
