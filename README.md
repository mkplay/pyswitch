
pySwitch
========

Switch easily between different versions of Python on Windows.

How To Use
----------
1. Download pySwitch
2. Pick one from the "config_samples" and rename it to "config.txt"
3. Edit the config to fit your needs
4. Run pySwitch.bat as administrator
5. Choose your desired option

The changes will take effect immediately except prior opened Windows command-line shells (cmd.exe) -
the Windows prompts keep the old values "by nature".

The Gist
--------
The pySwitch batch file has no dependencies except the built in "reg" and "setx" command.
Therefore it runs out of the box on each and every Windows system.

I have invested a little time in playing around (aka testing ;-) to assure that 
pySwitch nor clutters your registry neither removes vital entries from the system path.

Please understand: I can't guarantee - use pySwitch at your own risk.

Issues/ToDos
------------
- Add some commenting in the .bat
- Evaluate working with the global PATH vs. the local PATH

