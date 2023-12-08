# PowerShell script for generating a CPU Affinity table
# Can be pasted directly in PowerShell, instead of having to do a .ps1

# Get CPU Information
$cpuInfo = Get-WmiObject -Class Win32_Processor
$totalCores = $cpuInfo.NumberOfCores
$totalThreads = $cpuInfo.NumberOfLogicalProcessors

# Header
$outputBuilder = New-Object System.Text.StringBuilder
$outputBuilder.AppendLine(":: Affinity table for $cpuModel with Hyperthreading")

# Function to format BitMask
Function Format-BitMask ($affinityValue) {
    $bitMask = [Convert]::ToString($affinityValue, 2)
    # Ensure a minimum of 8 digits
    $formattedBitMask = $bitMask.PadLeft(8, '0')

    # Insert space before the last 8 characters
    if ($formattedBitMask.Length -gt 8) {
        $formattedBitMask = $formattedBitMask.Insert($formattedBitMask.Length - 8, ' ')
    }

    return $formattedBitMask
}

# Calculate the maximum length for Thread ID and Core Type
$maxCoreTypeLength = "E-Core".Length
$maxThreadIDLength = ($totalCores - 1).ToString().Length

# Adding Header for the table
$headerThread = "Thread #".PadRight($maxCoreTypeLength + 1 + $maxThreadIDLength)
$headerValue = "Value".PadRight(8)
$outputBuilder.AppendLine(":: $headerThread = $headerValue = BitMask")

# Generate table
for ($i = 0; $i -lt $totalThreads; $i++) {
    $affinityValue = 1 -shl $i
    $formattedBitMask = Format-BitMask -affinityValue $affinityValue
    
    # Core Type and ID
    $coreType = if ($i -lt $totalCores) { "P-Core" } else { "E-Core" }
    
    # Format and pad value for right alignment
    $valuePadded = $affinityValue.ToString().PadRight(8)

    # Format and pad thread ID for alignment
    $threadID = "$coreType $i"
    $threadIDPadded = $threadID.PadRight($maxCoreTypeLength + 1 + $maxThreadIDLength)

    # Accumulate Output
    $outputBuilder.AppendLine(":: $threadIDPadded = $valuePadded = $formattedBitMask")
}

# Print accumulated output
$outputBuilder.ToString()
