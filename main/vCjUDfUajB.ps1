$sourcePath = 'C:\source' 
$destPath = 'C:\destination' 
$logFile = 'C:\log.txt' 
function Copy-Files { 
    param ( 
        [string]$source, 
        [string]$destination 
    ) 
    Get-ChildItem -Path $source -File | ForEach-Object { 
        $dest = Join-Path -Path $destination -ChildPath $_.Name 
        Copy-Item -Path $_.FullName -Destination $dest 
        Add-Content -Path $logFile -Value "Copied: $($_.FullName) to $dest" 
    } 
} 
function Delete-EmptyFolders { 
    param ( 
        [string]$path 
    ) 
    Get-ChildItem -Path $path -Directory | ForEach-Object { 
        if (-Not (Get-ChildItem -Path $_.FullName)) { 
            Remove-Item -Path $_.FullName -Recurse 
            Add-Content -Path $logFile -Value "Deleted: $($_.FullName)" 
        } 
    } 
} 
Copy-Files -source $sourcePath -destination $destPath 
Delete-EmptyFolders -path $destPath 
$files = Get-ChildItem -Path $destPath -File 
$totalFiles = $files.Count 
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum 
Add-Content -Path $logFile -Value "Total files copied: $totalFiles" 
Add-Content -Path $logFile -Value "Total size of files: $totalSize bytes" 
$files | ForEach-Object { 
    $fileInfo = New-Object PSObject -Property @{ 
        Name = $_.Name 
        Size = $_.Length 
        CreationTime = $_.CreationTime 
    } 
    $fileInfo 
} | Export-Csv -Path 'C:\fileinfo.csv' -NoTypeInformation 
Start-Sleep -Seconds 5 
Get-Process | Where-Object {$_.CPU -gt 100} | ForEach-Object { 
    Stop-Process -Id $_.Id -Force 
    Add-Content -Path $logFile -Value "Stopped process: $($_.Name)" 
} 
