# vim-tabspace
VIM Tabspace makes it easier to use VIMs tabs as full workspaces.

VIM tabs, as most vim users have discovered, do not function like tabs in other editors.  They ideally function more like workspaces.

A few quirks of the tabs make this workspace concept imperfect though.  For example, windows either share the global working directory, or have a window specific working directory.

This plugin aims to make tabs into more functional workspaces. As of now, the plugin does the following:

* Change the current working directory on a per tab basis, only when requested.
* Allows giving tabs custom names and colors
* Allows starting VIM with a pre-configured set of tabs
* Allows opening pre-configured groups of tabs
* Integrates with NERDTree to change the working dir
