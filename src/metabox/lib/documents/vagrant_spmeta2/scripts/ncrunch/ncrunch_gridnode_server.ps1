# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Running NCrunch Grid Node Server configuration..."
Trace-MbEnv

$packageVersion      = Get-MbEnvVariable "NCRUNCH_GRIDNODE_VERSION"
$domainUserName      = Get-MbEnvVariable "NCRUNCH_GRIDNODE_USER_NAME"
$domainUserPassword  = Get-MbEnvVariable "NCRUNCH_GRIDNODE_USER_PASSWORD"

$securePassword = ConvertTo-SecureString $domainUserPassword -AsPlainText -Force
$domainUserCreds = New-Object System.Management.Automation.PSCredential($domainUserName, $securePassword)

Configuration Install_NCrunchGridNodeServer
{
    Import-DscResource -Module CChoco
   
    Node localhost
    { 
        cChocoPackageInstaller NCrunchGrid
        {
            Name                 = 'ncrunch-gridnodeserver'
            Ensure               = 'Present'
            AutoUpgrade          = $false
            Version              = $Node.PackageVersion
        }

        File NCrunchGridWorkingFolder {
            DependsOn       = "[cChocoPackageInstaller]NCrunchGrid"
            Type            = 'Directory'
            DestinationPath = 'C:\_ncrunch'
            Ensure          = "Present"
        }

        Registry NCrunchGridRegPassword {
            DependsOn   = "[File]NCrunchGridWorkingFolder"
            Ensure      = "Present"
            Key         = "HKLM:\SOFTWARE\Remco Software\NCrunch Grid Node"
            ValueName   = "Password"
            ValueData   = "l1baZf5Srvt2UfUmYpuaBM9hGRcsqjv+An/SokCfzk8="
            ValueType   = "String" 
        }

        Registry NCrunchGridRegWorkingDir {
            DependsOn   = "[File]NCrunchGridWorkingFolder"
            Ensure      = "Present"
            Key         = "HKLM:\SOFTWARE\Remco Software\NCrunch Grid Node"
            ValueName   = "SnapshotStorageDirectory"
            ValueData   = "C:\_ncrunch"
            ValueType   = "String" 
        }

        Service NCrunchGridService
        {
            DependsOn       = "[Registry]NCrunchGridRegPassword", "[Registry]NCrunchGridRegWorkingDir"
            
            Name            = "NCrunchGridNode"
            StartupType     = "Automatic"
            State           = "Running"

            Credential      = $domainUserCreds
        }      
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'

            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            
            RetryCount = 10           
            RetryIntervalSec = 30

            PackageVersion  = $packageVersion
        }
    )
}

# install grid node server
Log-MbInfoMessage "Installing grid node server..."
Apply-MbDSC "Install_NCrunchGridNodeServer" $config 

exit 0