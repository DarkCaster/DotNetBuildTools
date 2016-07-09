$scriptPathExist = Get-Variable -Name script_dir -Scope Local -ErrorAction SilentlyContinue

if ($scriptPathExist -eq $null)
{
    $script_dir = split-path -parent $MyInvocation.MyCommand.Definition
}

function log
{
    $msg=$args[0]
    Write-Host "$msg"
    Write-Output $msg | Out-File -Append "$script_dir\logfile.txt"
}

function clear_log () {
    Write-Output "Logfile cleared" | Out-File "$script_dir\logfile.txt"
}

function check_error () {
    if(!($?))
    {
	    log "Error detected in last command"
        exit 1
    }
}

function unzip($file, $destination)
{
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items())
    {
        $shell.Namespace($destination).copyhere($item)
    }
}
