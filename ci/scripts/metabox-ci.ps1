$ErrorActionPreference = "Stop"

# helpers - start
function Log-MbMessage($message, $level) {
    $stamp = $(get-date -f "MM-dd-yyyy HH:mm:ss.fff")
    $logMessage = "METABOX-CI: $stamp : $level : $([environment]::UserDomainName)/$([environment]::UserName) : $message"

    Write-Host $logMessage -Fore Magenta
}

function Log-MbInfoMessage($message) {
    Log-MbMessage "$message" "INFO"
}

function Validate-MbExitCode {
    Param(
        [Parameter(Mandatory=$True)]
        $code,
        
        [Parameter(Mandatory=$True)]
        $message,

        [Parameter(Mandatory=$False)]
        $allowedCodes = @( 0 )
    )

    $valid = $false

    Log-MbInfoMessage "Checking exit code: $code with allowed values: $allowedCodes"

    foreach ($allowedCode in $allowedCodes) {
        if($code -eq $allowedCode) {
            $valid = $true
            break
        }
    }
    
    if( $valid -eq $false) {
        $error_message =  "$message - exit code is: $code but allowed values were: $allowedCodes"
        
        Log-MbInfoMessage $error_message
        throw $error_message
    } else {
        Log-MbInfoMessage "Exit code is: $code within allowed values: $allowedCodes"
    }

    return $code
}

# helpers - end

# ci helpers - start
function Is-WindowsOS() {
    Log-MbInfoMessage "Detecting OS..."
    
    $osName = [environment]::OSVersion.ToString()
    $result = ($osName.Contains("Windows") -eq $true)

    if ($result -eq $true) {
        Log-MbInfoMessage " - Windows OS detected: $osName"
    } else {
        Log-MbInfoMessage " - Non-Windows OS detected: $osName"
    }

    return $result
}



function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

function Ensure-SwarmClient {
    
    $clientFileName = "swarm-client-3.5.jar"
    $dir = Get-ScriptDirectory
    $filePath = $dir  + "/" + $clientFileName

    $httpFilePath = "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.5/swarm-client-3.5.jar"

    Log-MbInfoMessage "Checking if Swarm client exists: $filePath"
    
    if(!(Test-Path $filePath)) {
        Log-MbInfoMessage " - cannot find file, will download one: $filePath"
        
        $windowsOS = Is-WindowsOS

        if($windowsOS -eq $true) {
            $wget_cmd = "C:\ProgramData\chocolatey\bin\wget.exe -O ""$filePath"" ""$httpFilePath"""
            cmd /c $wget_cmd 

            Validate-MbExitCode $LASTEXITCODE "Cannot download file with wget. cmd was: $wget_cmd"

        } else {
            $wget_cmd = "wget -O '$filePath' '$httpFilePath'"
            sh -c $wget_cmd 

            Validate-MbExitCode $LASTEXITCODE "Cannot download file with wget. cmd was: $wget_cmd"
        }
    } else {
        Log-MbInfoMessage " - found file: $filePath"
    }
}

function Init-SlaveWindows() {
    Param(
        [Parameter(Mandatory=$True)]
        $portNumber,
        
        [Parameter(Mandatory=$True)]
        $slaveName,

        [Parameter(Mandatory=$False)]
        $masterUrl,

        [Parameter(Mandatory=$False)]
        $slaveLabels
    )

    Log-MbInfoMessage "Initializing slave on port: $portNumber"

    # checking if is here swarm-client-3.5.jar
    Ensure-SwarmClient
    
    $currentDir = Get-ScriptDirectory
    Log-MbInfoMessage " - current dir: $currentDir"
    
    if( [System.String]::IsNullOrEmpty($masterUrl)) {
        $masterUrl = "http://localhost:$portNumber"
    } else {
        $masterUrl = $masterUrl + ":" + $portNumber
    }

    if( [System.String]::IsNullOrEmpty($slaveLabels)) {
        $slaveLabels = "metabox"
    }

    $cmd = @(
        "-jar",
        "$currentDir/swarm-client-3.5.jar",
        "-name ""$slaveName""",
        "-disableSslVerification",
        "-master ""$masterUrl""",
        "-username metabox",
        "-password metabox",
        "-labels ""$slaveLabels"" ",
        "-fsroot ""$env:temp\metabox-ci\$slaveName"" "
    )

    $cmd_string = [String]::Join(" ", $cmd)
    Log-MbInfoMessage " - running: $cmd_string"

    $result = Start-Process "java.exe" -ArgumentList $cmd -NoNewWindow -PassThru

    if( $result -eq $null) {
      throw "Cannot start process in backgroud"
    }

    # # we run slave in the background with "&" switch
    # # checking if there is a process and if there is none, then fail
    $pid_value = Find-SlavePidWindows $portNumber

    if ($pid_value -eq $null) {
        $errorMessage = "Cannot start slave. Port number: $portNumber  Name: $slaveName"

        Log-MbInfoMessage $errorMessage 
        throw $errorMessage 
    } else {
         Log-MbInfoMessage "Started slave: PID: $pid_value, Port number: $portNumber  Name: $slaveName"
    }

    return $pid_value
}

function Init-SlaveMac {

    Param(
        [Parameter(Mandatory=$True)]
        $portNumber,
        
        [Parameter(Mandatory=$True)]
        $slaveName,

        [Parameter(Mandatory=$False)]
        $masterUrl,

        [Parameter(Mandatory=$False)]
        $slaveLabels
    )

    Log-MbInfoMessage "Initializing slave on port: $portNumber"

    # checking if is here swarm-client-3.5.jar
    Ensure-SwarmClient
    
    $currentDir = Get-ScriptDirectory
    Log-MbInfoMessage " - current dir: $currentDir"

    if( [System.String]::IsNullOrEmpty($masterUrl)) {
        $masterUrl = "http://localhost:$portNumber"
    } else {
        $masterUrl = $masterUrl + ":" + $portNumber
    }

    if( [System.String]::IsNullOrEmpty($slaveLabels)) {
        $slaveLabels = "metabox"
        Log-MbInfoMessage " - using DEFAULT labels: $slaveLabels"
    } else {
        Log-MbInfoMessage " - using labels: $slaveLabels"
    }
    
    $tmpPath = [System.IO.Path]::GetTempPath()

    $cmd = @(
        "java",
        "-jar",
        "$currentDir/swarm-client-3.5.jar",
        "-name '$slaveName'",
        "-disableSslVerification",
        "-master ""$masterUrl""",
        "-username metabox",
        "-password metabox",
        "-labels '$slaveLabels' "
        "-fsroot ""$tmpPath/metabox-ci/$slaveName"" "
        #"&"
    )

    $cmd_string = [String]::Join(" ", $cmd)
    Log-MbInfoMessage " - running: $cmd_string"

    sh -c $cmd_string
    
    # we run slave in the background with "&" switch
    # checking if there is a process and if there is none, then fail
    $pid_value = Find-SlavePidMac $portNumber

    if ($pid_value -eq $null) {
        $errorMessage = "Cannot start slave. Port number: $portNumber  Name: $slaveName"

        Log-MbInfoMessage $errorMessage 
        throw $errorMessage 
    }

    return $pid_value
}

function Find-SlavePidMac {

    Param(
        [Parameter(Mandatory=$True)]
        $portNumber
    )

    $pid_value = $null
    Log-MbInfoMessage "Looking for slave on port: $portNumber"

    $pid_cmd     = "ps | grep 'java.*localhost:$portNumber' | grep -v grep |  awk '{print $1}'"   
    $pid_result  = (sh -c $pid_cmd)

    if ($pid_result -ne $null) {
        Log-MbInfoMessage " - result: $pid_result"
        $pid_value = $pid_result.Split(' ')[0]
    }

    Log-MbInfoMessage " - pid: $pid_value"

    return $pid_value
}

function Find-SlavePidWindows {
    Param(
        [Parameter(Mandatory=$True)]
        $portNumber
    )

    $pid_value = $null
    Log-MbInfoMessage "Looking for slave on port: $portNumber"

    $javaProcesses = @() + (Get-WmiObject Win32_Process -Filter "name = 'java.exe'")

    foreach($javaProcess in $javaProcesses) {
        
        if($javaProcess.CommandLine -ne $null -and $javaProcess.CommandLine.ToString().Contains("localhost:$portNumber") -eq $true) {
            $pid_value = $javaProcess.ProcessId
        }
    }

    return $pid_value
}

function Destroy-SlaveWindows {
    Param(
        [Parameter(Mandatory=$True)]
        $portNumber
    )

    Log-MbInfoMessage "Killing slave on port: $portNumber"
    $pid_value = Find-SlavePidWindows $portNumber

    Log-MbInfoMessage " - found pid: $pid_value" -Fore Green
   
    if ($pid_value -ne $null) {
        Log-MbInfoMessage " - killing process by PID: $pid_value"
        Stop-Process $pid_value -Force
    } else {
        Log-MbInfoMessage " - PID is null, skipping process kill"
    }
}



function Destroy-SlaveMac {

    Param(
        [Parameter(Mandatory=$True)]
        $portNumber
    )

    Log-MbInfoMessage "Killing slave on port: $portNumber"
    $pid_value = Find-SlavePidMac $portNumber

    Log-MbInfoMessage " - found pid: $pid_value" -Fore Green
   
    if ($pid_value -ne $null) {
        Log-MbInfoMessage " - killing process by PID: $pid_value"
        sh -c "kill -9 $pid_value"
    } else {
        Log-MbInfoMessage " - PID is null, skipping process kill"
    }
}
# ci helpers - end
function Mb-ShutdownSlave {
    Param(
        [Parameter(Mandatory=$True)]
        $portNumber,
        
        [Parameter(Mandatory=$True)]
        $slaveName
    )

    $windowsOS = Is-WindowsOS

    if($windowsOS -eq $true) {
        Destroy-SlaveWindows $portNumber
    } else {
        Destroy-SlaveMac  $portNumber
    }
}

function Mb-InitSlave {
    Param(
        [Parameter(Mandatory=$True)]
        $portNumber,
        
        [Parameter(Mandatory=$True)]
        $slaveName,

        [Parameter(Mandatory=$False)]
        $masterUrl,

        [Parameter(Mandatory=$False)]
        $slaveLabels
    )
    $windowsOS = Is-WindowsOS

    if($windowsOS -eq $true) {
        Init-SlaveWindows  -portNumber $portNumber `
                           -slaveName $slaveName `
                           -masterUrl $masterUrl `
                           -slaveLabels $slaveLabels
    } else {
        Init-SlaveMac   -portNumber $portNumber `
                        -slaveName $slaveName `
                        -masterUrl $masterUrl `
                        -slaveLabels $slaveLabels
    }
}

function Mb-RestartSlave {
    Param(
        [Parameter(Mandatory=$True)]
        $portNumber,
        
        [Parameter(Mandatory=$True)]
        $slaveName
    )
    
    Mb-ShutdownSlave $portNumber $slaveName
    Mb-InitSlave $portNumber $slaveName
}