## Metabox file resources

Before reading this, make sure you are familiar with metabox document concepts. This section focuses on how meabox file resources works; from downloading, packaging, to passing to Packer builds and Vagrant VMs.

### Problem
While provisioning complex environments such as SQL or SharePoint, additional files have to be downloaded; ISO images and installation media. Not only we might have many files to download and managed, but they are also quite huge, from 500Mb to 3-4Gb, and hence the following challenges arise straight away:
* how to define all these files
* how to download them
* where and how to store them
* how to pass them to Packer builds
* how to pass them to Vagrant VMs

Downloading and storing files is not something new but passing them to Packer builds and Vagrant VMs might be quote a challenge: different hyper-visor might or might not provide a good file transfer capabilities, Packer and Vagrant handle this operation differently, besides Vagrant might perform fast on windows 2012 but slow on windows 2016.

Downloading is another challenge; we need to ensure files are downloaded correctly.

Finally, storing these files could be a challenge itself; total amount of data might be around 50-75Gb which could impact your storage. It should be easier to plug additional storage and re-point metabox to this storage.

As you can see, file handling is a problem itself. Hence, metabox solves it providing a built-in, consistent experience over the following areas:

* defining files in metabox documents along with packer/vagrant builds and VMs
* downloading files, using SHA1 hash to check file integrity and avoid re-downloading
* built-in pre/post download script hook (metabox executes your scripts before/after file downloads)
* built-in capabilities to transfer huge files into Packer builds (via http_directory virtual box feature)
* built-in capabilities to transfer huge files into Vagrant VMs (via sinatra based local http web server)
* built-in scripts to pack/unpack huge files into smaller zip files, ISO unpacking 

All this gives you a fluent experience over file downloading and transferring them into Packer/Vagrant so that you can focus on provisioning instead.

### Defining what to download
Metabox document is used to define what to download and where to store it. Here is a very simple configuration which gets 7zip files downloaded:

```yaml
Metabox:
  Description: Downloads additional software
    
  Resources:
    7zip:
      Type: "metabox::http::file_set"
      Resources:
        7zip-17.01-x86:
          Type: "metabox::http::file"
          Properties:
            SourceUrl: "http://www.7-zip.org/a/7z1701.exe"
            DestinationPath: "${ENV:METABOX_DOWNLOADS_PATH}/7zip/7z1701-x86.exe"
            Checksum:
              Enabled: true
              Type: "sha1"
              Value: "2c94bd39e7b3456873494c1520c01ae559bc21d7" 
            Hooks:
              Pre: 
                Inline: 
                  - "echo 'pre-download'" 
              Post: 
                Inline: 
                  - "echo 'post-download'"       
        
        7zip-17.01-x64:
          Type: "metabox::http::file"
          Properties:
            SourceUrl: "http://www.7-zip.org/a/7z1701-x64.exe"
            DestinationPath: "${ENV:METABOX_DOWNLOADS_PATH}/7zip/7z1701-x64.exe"
            Checksum:
              Enabled: true
              Type: "sha1"
              Value: "9f3d47dfdce19d4709348aaef125e01db5b1fd99" 
            Hooks:
              Pre: 
                Inline: 
                  - "echo 'pre-download'" 
              Post: 
                Inline: 
                  - "echo 'post-download'"       
        

```

Metabox uses "metabox::http::file_set" resource - a set of individual file. Such resource then has got nested resources of type "metabox::http::file". It makes it easier to manage and download either one file or all files in a batch.

Internally, metabox spins 5 threads to download all files in the fileset. If checksum flag is "true", then metabox checks if local file has got the right checksum avoiding another trip to re-download file.

"METABOX_DOWNLOADS_PATH" environment variable is used to store files. By default, metabox used "METABOX_WORKING_DIR\metabox_downloads" path but you can change it as you wish. That makes it possible to use external drives or other drives to store and manage installation media.

Finally, before-after download a custom script is called via "Pre/Post" hooks. Current directory is set to the downloaded file directory so you can refer to file by its name. Later, we use these hooks to package large files with 7zip into smaller, 500Mb zip archives as this:

```yaml
Metabox:
  Description: Downloads SharePoint Designer
    
  Resources:
    spd2013:
      Type: "metabox::http::file_set"
      Resources:  
        spd_x32:
          Type: "metabox::http::file"
          Properties:
            SourceUrl: "https://download.microsoft.com/download/3/E/3/3E383BC4-C6EC-4DEA-A86A-C0E99F0F3BD9/sharepointdesigner_32bit.exe"
            DestinationPath: "${ENV:METABOX_DOWNLOADS_PATH}/spd2013_x32/sharepointdesigner_32bit.exe"
            Checksum:
              Enabled: true
              Type: "sha1"
              Value: "7be30cadc49d66f116ab4aa303bbfed937846825" 
            Hooks:
              Pre: 
                Inline: 
                  - "echo 'pre-download'" 
              Post: 
                Inline: 
                  - "7z -v500m a zip/dist.zip sharepointdesigner_32bit.exe" 
        spd_x64:
          Type: "metabox::http::file"
          Properties:
            SourceUrl: "https://download.microsoft.com/download/3/E/3/3E383BC4-C6EC-4DEA-A86A-C0E99F0F3BD9/sharepointdesigner_64bit.exe"
            DestinationPath: "${ENV:METABOX_DOWNLOADS_PATH}/spd2013_x64/sharepointdesigner_64bit.exe"
            Checksum:
              Enabled: true
              Type: "sha1"
              Value: "60041617c421962c28e71f712e299e29f51651fb" 
            Hooks:
              Pre: 
                Inline: 
                  - "echo 'pre-download'" 
              Post: 
                Inline: 
                  - "7z -v500m a zip/dist.zip sharepointdesigner_64bit.exe"
```

### Huge files handling
Metabox provides "Pre/Post" hooks to execute your scripts. By default, we package all files with "7zip" into smaller, 500Mb archives with the following cmd:

```
"7z -v500m a zip/dist.zip sharepointdesigner_64bit.exe"
```
 
Every file resource then would have a "zip" folder, which then later exposed to Packer and Vagrant:
* Packer -> virtual box, "http_directory" is used
* Vagrant -> local web server based on "sinatra" is used

Under packer, you can access these files under "PACKER_HTTP_ADDR" environment variable. Sometime this variables is null (under windows 2008 host), so script simple scans all ports between 8000-9000 to find active web-server provided by Virtual Box.

Under vagrant, metabox spins up a local web server with "sinatra" and then passes "METABOX_HTTP_ADDR" variable to builds scripts.

Finally, "_metabox_dist_helper.ps1" checks all these environment variables and makes file downloads to the target host; either under Packer or Vagrant. This is very cool, a consistent approach to transfer files plus it works well on huge, really large files. It makes it also easier to migrate this project to AWS/Azure environments; simple "METABOX_HTTP_ADDR" variable would enable easy web transfer for these builds.

As metabox exposes "ENV:METABOX_DOWNLOADS_PATH" folder over HTTP, passing either "PACKER_HTTP_ADDR" or "METABOX_HTTP_ADDR" to host VMs, we can refer to files by their "resource name" and "zip" folders. "_metabox_dist_helper.ps1" uses "METABOX_RESOURCE_NAME" variables to fetch all "zip" files, download them, unpack, detect ISO and unpack it, or detect non-iso and move it to "METABOX_RESOURCE_DIR". 

What you get at the end, is "METABOX_RESOURCE_DIR" on target VM folder which looks like a replica of "METABOX_DOWNLOADS_PATH" for a giving resource.





 

