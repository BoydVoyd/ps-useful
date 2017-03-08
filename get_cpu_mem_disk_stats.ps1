#Start PSRemoting 
Invoke-Command -ComputerName (Get-Content .\Serverlist.txt) -scriptblock { 
#Run the commands concurrently for each server in the list

$DiskInfo = Get-WMIObject Win32_LogicalDisk -Filter "DriveType='3'" 
$ComputerInfo = Get-WmiObject Win32_ComputerSystem #Get Computer Information
$CPUInfo = Get-WmiObject Win32_Processor #Get CPU Information 
$OSInfo = Get-WmiObject Win32_OperatingSystem #Get OS Information 
$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory | Measure-Object -Property capacity -Sum | % {[math]::round($_.sum / 1GB)} 
$DiskAllocated = [math]::round(($DiskInfo | Measure-Object -Property size -Sum).Sum / 1GB)
$DiskFree = [math]::round(($DiskInfo | Measure-Object -Property freespace -Sum).Sum / 1GB)
$DiskUsed = ($DiskAllocated - $DiskFree)
$infoObject = New-Object PSObject 

#Get Memory Information. The data will be shown in a table as MB, rounded to the nearest second decimal. 
#$OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2) 
#$OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize  / 1MB), 2) 


#The following add data to the infoObjects. 


#Reset number of cores and use count for the CPUs counting
           $Sockets = 0;
           $Cores = 0;
           
           foreach($Processor in $CPUInfo){

           $Sockets = $Sockets+1;   
           
           #count the total number of cores         
           $Cores = $Cores+$Processor.NumberOfCores;
        
          } 
          
Add-Member -inputObject $infoObject -memberType NoteProperty -name "ServerName" -value $ComputerInfo.Name
Add-Member -inputObject $infoObject -memberType NoteProperty -name "Sockets" -value $Sockets
Add-Member -inputObject $infoObject -memberType NoteProperty -name "Cores" -value $Cores
Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalPhysical_Memory_GB" -value $PhysicalMemory 
Add-Member -inputObject $infoObject -memberType NoteProperty -name "Disk_Allocated_GB" -value $DiskAllocated
Add-Member -inputObject $infoObject -memberType NoteProperty -name "Disk_Used_GB" -value $DiskUsed
Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Name" -value $OSInfo.Caption 
Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Version" -value $OSInfo.Version 

#Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVirtual_Memory_MB" -value $OSTotalVirtualMemory 
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVisable_Memory_MB" -value $OSTotalVisibleMemory 
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_SocketDesignation" -value ($CPUInfo | Select SocketDesignation -Unique | Measure-Object).count
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L2CacheSize" -value $CPUInfo.L2CacheSize 
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L3CacheSize" -value $CPUInfo.L3CacheSize 
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "ServerName" -value $#$CPUInfo.SystemName 
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_Name" -value $CPUInfo.Name 
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_Description" -value $CPUInfo.Description 
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_Manufacturer" -value $CPUInfo.Manufacturer 
#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_NumberOfCores" -value $CPUInfo.NumberOfCores 



$infoObject 
} | Select-Object * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName | Export-Csv -path .\Server_Inventory_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation