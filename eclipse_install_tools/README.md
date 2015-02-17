Eclipse installation tool
-------------------------

A simple shell script to install eclipse, plugins and dropins 
via commandline.

It's quite simple to add your own plugins and dropins to the configuration,
see the files in the subdirs plugin-info and dropin-info.


```
 Usage: eclipse_install_tools/install_eclipse.sh -t <installation dir> [-y] [-p <plugin name>] [-d <dropin name>]
  
        -y -- don't show the confirmation dialog
        -p -- installs the plugin defined in plugin-info/<plugin name>.pi
        -d -- installs the dropin defined in drop-info/<dropin name>.di
 
 Several dropins and plugins can be separated by comma.
```

## Example

Install a eclipse with findbugs and checkstyle

```
  ./install_eclipse.sh -t /home/tools/luna -p findbugs,checkstyle

```
