-- Prose is one sentence per line and never hard-wrapped. The runtime ftplugin
-- adds "t", and an editorconfig max_line_length would give it a textwidth to
-- wrap at, so drop it here.
vim.opt_local.formatoptions:remove("t")
