using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Interact with query parameters or the body of the request.
$RGName = $Request.Query.RGName # Query based parameters ()
if (-not $RGName) {$RGName = $Request.Body.RGName} # JSON Body (POST)

$VMName = $Request.Query.VMName # Query based parameters ()
if (-not $VMName) {$VMName = $Request.Body.VMName} # JSON Body (POST)

# Get the Azure VM status
$vmmetadata = (Get-AzVM -ResourceGroupName $RGName -Name $VMName)

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $vmmetadata
        headers    = @{ "content-type" = "application/json" }
    })