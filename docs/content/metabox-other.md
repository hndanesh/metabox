# Misc

This section describes various tips & trick which could be of use while working on Windows/MacOS platforms.

Check out particular guide on the right.

## MacOS notes

This section describes various MacOS relates tips & tricks, user experience which has had while using metabox.

### Useful  tooling
* brew (recommended)
* iTerm2 (recommended)

### RDP clients
* Microsoft Remote Desktop for MacOS
* Royal TSX (recommended)
* CoRD: Remote Desktop for Mac OS X

### Keys remapping tools
* Karabiner (recommended)
* sharpkeys 

### Key mapping over RDPs - Mac -> Win
While working on MacOS with Windows, it might be useful to remap left control/option key in MacOS to left control on the target Windows. In reality, this could be much harder to figure out that it looks like:
* we want to leave default/changed mapping in MacOS
* we want to apply changed mapping only while we are on Win within RDP

Here are a few notes which can be useful:
* MacOS + VirtualBox + sharpkeys on guest win -> can work well but isn't scalable solution
* MacOS + RDP client + sharpkeys -> may not work well, some keys won't be mapped/pass right
* MacOS + Royal TSX + Karabiner (update left keys only for VMs/RDPs)  -> recommended, works well

Other combinations, other than MacOS + Royal TSX + Karabiner, have not been tested much. You may find remapping experience rather frustrating with other toolchain combination.

