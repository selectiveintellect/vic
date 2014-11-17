# Microchip's PICKit 2 Starter Kit

The `pk2cmd` tool is provided here as a way to avoid problems resulting from
the changing state of Microchip's original [PICKit 2 Starter Kit](http://www.microchip.com/pickit2/) website.

We have the following available files for the user:

- [Windows Commandline Source v1.20](pickit2/PICkit2_PK2CMD_WIN32_SourceV1-20.zip)
- [Windows Desktop App Source v2.61](pickit2/PICkit2_PCAppSource_V2_61.zip)
- [Linux and Mac OSX Source v1.20](pickit2/pk2cmdv1.20LinuxMacSource.tar.gz)
- [Firmware Update v2.32](pickit2/FirmwareV2-32-00.zip)

## Installation Notes for Linux and Mac OS X

If you have `pk2cmd` installed in `/usr/local` you will need to set the `PATH`
variable as follows before doing the write to the microcontroller:

    $ export PATH=${PATH}:/usr/local/bin:/usr/share/pk2

You may also want to add the following to your `udev` rules directory as the
file `99_pickit2.rules`:

    $ cat > /etc/udev/rules.d/99_pickit2.rules 
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="04d8",
    ATTR{idProduct}=="0033", MODE="0664", GROUP="plugdev" SYMLINK+="pickit2"

This will create a `/dev/pickit2` symlink to your programmer as well. It is a
good way to test if your programmer was loaded correctly or not.

Before you run `pk2cmd` on Mac OS X, you will need to set the `lsusb` command
which is available on Linux but not on the Mac but is used by `pk2cmd`
internally.

    $ alias lsusb="system_profiler SPUSBDataType"

You may need to set these in the `~/.bashrc` or `~/.profile` of your shell to avoid
having to run these steps every time.

@@NEXT@@ install.md @@PREV@@ install.md
