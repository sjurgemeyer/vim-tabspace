# vim-tabspace
VIM Tabspace makes it easier to use VIMs tabs as full workspaces.

VIM tabs, as most vim users have discovered, do not function like tabs in other editors.  They ideally function more like workspaces.

A few quirks of the tabs make this workspace concept imperfect though.  For example, windows either share the global working directory, or have a window specific working directory.

This plugin aims to make tabs into more functional workspaces. As of now, the plugin does the following:

* Change the current working directory on a per tab basis, only when requested.
* Allows creating pre-configured, named tabs to be opened when the editor starts, or ad hoc by specifying the name
* Allows giving tabs custom labels and colors, either configured ahead of time or ad-hoc
* Show buffer lists specific to the current tab
* Integrates with NERDTree to change the working dir


Example config
```
let g:add_tabspace_nerdtree_mappings = 1
let g:add_tabspace_mappings = 1

let g:initial_tabspaces = ['monolith', 'awesome']

let g:named_tabspaces = {
	\ 'monolith' : { 'cwd' : '~/projects/mycompany/monolith', 'label' : 'Old project' },
	\ 'awesome' : { 'cwd' : '~/projects/mycompany/newawesomeproject', 'label' : 'New Awesome Project' },
	\ 'sideproject' : { 'cwd' : '~/projects/personal/mysideproject', 'label' : 'Side Project' }
	\}
```
