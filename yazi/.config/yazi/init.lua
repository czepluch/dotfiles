-- Yazi plugin setup

-- Feed zoxide's frecency database while navigating in yazi
require("zoxide"):setup { update_db = true }

-- Git status signs in the file list (fetchers configured in yazi.toml)
require("git"):setup()

-- Rounded border around the whole UI
require("full-border"):setup { type = ui.Border.ROUNDED }

-- Open all selected files at once when pressing l on a file
require("smart-enter"):setup { open_multi = true }

-- Folder-specific sorting rules (local plugin)
require("folder-rules"):setup()
