# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Running NCrunch Grid Node configuration..."
Trace-MbEnv

$packageName     = Get-MbEnvVariable "METABOX_NCRUNCH_PLUGIN_NAME"
$packageVersion  = Get-MbEnvVariable "METABOX_NCRUNCH_PLUGIN_VERSION"

Configuration Install_NCrunchPlugin
{
    Import-DscResource -Module CChoco
   
    Node localhost
    { 
        cChocoPackageInstaller NCrunchVs
        {
            Name                 = $Node.PackageName
            Ensure               = 'Present'
            AutoUpgrade          = $false
            Version              = $Node.PackageVersion
        }        
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'

            PSDscAllowPlainTextPassword = $true
            
            RetryCount       = 10           
            RetryIntervalSec = 30

            PackageName     = $packageName
            PackageVersion  = $packageVersion
        }
    )
}

Apply-MbDSC "Install_NCrunchPlugin" $config 

exit 0