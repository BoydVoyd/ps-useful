#Start PSRemoting 
$results = Invoke-Command -scriptblock { 
#Run the commands concurrently for each server in the list

    $adapters=(gwmi win32_networkadapterconfiguration )
    Foreach ($adapter in $adapters){
        $adapter.settcpipnetbios(2)
        }
}
