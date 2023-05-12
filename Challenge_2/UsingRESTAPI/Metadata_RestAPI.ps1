#Note : The REST method only works from Inside Instance since the IP 169.254.169.254 is exposed only to Azure internally and not reachable from Public internet.

# Retrieve Azure VM Instance Metadata using Azure REST Service
$instanceMetadataUri = "http://169.254.169.254/metadata/instance?api-version=2021-02-01&format=json"
$instanceMetadata = Invoke-RestMethod -Uri $instanceMetadataUri -Headers @{"Metadata"="true"} -Method GET

# Filter Key you want to retrieve
$key = "network"

# Check if the key exists in the metadata
if ($instanceMetadata.PSObject.Properties.Name -contains $key) {
    # Retrieve the value for the specified key
    $value = $instanceMetadata.network.interface.ipv4.ipAddress

    # Convert the value to JSON
    $valueJson = ConvertTo-Json $value -Depth 4

    # Print the JSON-formatted value
    $valueJson
}
else {
    Write-Host "The specified key does not exist in the instance metadata."
}