# Debugging Avante Diff Review

## Step-by-step test:

1. **Create a test file:**
   ```bash
   echo "pub fn test() { 1 + 1 }" > /tmp/test.gleam
   nvim /tmp/test.gleam
   ```

2. **Open Avante and ask for a change:**
   - Press `<leader>aa` (opens sidebar)
   - Type: "change this to multiply instead of add"
   - Press `<CR>` to submit

3. **Wait for response to generate**
   - You should see the AI's response in the sidebar
   - The response should include a code block with the change

4. **Check where your cursor is:**
   - Press `<C-w>w` to cycle through windows
   - Make sure you're in the **SIDEBAR** (the one with AI's response)
   - You should see text like "```gleam" and code

5. **Apply the changes:**
   - While in the sidebar, press `A` (capital A)
   - This should create conflict markers in `/tmp/test.gleam`

6. **Switch to your code file:**
   - Press `<C-w>w` to switch to the code window
   - You should now see conflict markers:
     ```
     <<<<<<< CURRENT
     pub fn test() { 1 + 1 }
     =======
     pub fn test() { 1 * 1 }
     >>>>>>> INCOMING
     ```

7. **Review and accept:**
   - Press `]x` to jump to the conflict
   - Press `ct` to accept the AI's version
   - Or manually edit before accepting

## If step 5 gives "modifiable is off":

Check which buffer you're in:
```vim
:echo bufname('%')
```

Should show something like: `avante://...` (the sidebar buffer)

If it shows the actual file path, you're in the wrong buffer.

## If no conflict markers appear in step 6:

1. Check if the file was modified at all:
   ```vim
   :echo &modified
   ```

2. Check Avante logs:
   ```vim
   :messages
   ```

3. Try with `mode = "legacy"` and see if behavior changes

## Alternative: Test with direct API

If the above doesn't work, try calling the apply function directly:

```vim
:lua require('avante').get():apply(false)
```

This bypasses keybindings and calls apply directly.
