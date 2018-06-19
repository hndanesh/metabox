# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing additional development software..."
Trace-MbEnv

Configuration Install_DevelopmentSoftware
{
    Import-DscResource -Module CChoco
   
    Node localhost
    { 
        cChocoPackageInstaller 7zip
        {
            Name                 = '7zip'
            Ensure               = 'Present'
        }

        cChocoPackageInstaller ilspy
        {
            Name                 = 'ilspy'
            Ensure               = 'Present'
        }

        cChocoPackageInstaller ulsviewer
        {
            Name                 = 'ulsviewer'
            Ensure               = 'Present'   
        }

        cChocoPackageInstaller sharepointmanager2013
        {
            Name                 = 'sharepointmanager2013'
            Ensure               = 'Present'   
        }

        cChocoPackageInstaller googlechrome
        {
            Name                 = 'googlechrome'
            Ensure               = 'Present'   
        }

        cChocoPackageInstaller firefox
        {
            Name                 = 'firefox'
            Ensure               = 'Present'   
        }

        cChocoPackageInstaller git
        {
            Name                 = 'git'
            Ensure               = 'Present'   
        }
    
        cChocoPackageInstaller visualstudiocode
        {
            Name                 = 'visualstudiocode'
            Ensure               = 'Present'   
        }
       
        cChocoPackageInstaller cmder
        {
            Name                 = 'cmder'
            Ensure               = 'Present'   
        }
    }
}

# dsc config
$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            RetryCount = 10           
            RetryIntervalSec = 30
        }
    )
}

Apply-MbDSC "Install_DevelopmentSoftware" $config 

exit 0