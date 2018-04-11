# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Configuring installing updates from Windows Update Center..."
Trace-MbEnv

Configuration ConfigureUpdateSource
{
    Node localhost {

        Registry UpdateFromWindowsUpdateCenterEnable
        {
            Ensure      = "Present"
            Key         = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing"
            ValueName   = "LocalSourcePath"
            ValueType   = "ExpandString"
        }

        Registry UpdateFromWindowsUpdateCenter
        {
            Ensure      = "Present"
            Key         = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing"
            ValueName   = "RepairContentServerSource"
            ValueType   = "DWORD"
            ValueData   = "2"
            DependsOn   = "[Registry]UpdateFromWindowsUpdateCenterEnable"
        }

    }
}

Log-MbInfoMessage "Configuring installing updates from Windows Update Center..."
Apply-MbDSC "ConfigureUpdateSource"

exit 0