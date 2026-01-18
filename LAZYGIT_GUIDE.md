# Lazygit Learning Guide & Cheatsheet

## Quick Start

```bash
lazygit
# or
lg  # if you have an alias set up
```

---

## Exercises to Get Familiar with Lazygit

Complete these exercises in order within a test repository to build muscle memory.

### Exercise 1: Navigate the UI
**Goal:** Learn the main panels and navigation

1. Open lazygit in any git repo: `lazygit`
2. Notice the 4 main panels:
   - **Files** (top-left): Unstaged changes
   - **Staging** (top-right): Staged changes
   - **Branches** (bottom-left): All branches
   - **Log** (bottom-right): Commit history
3. Press `1` to focus Files panel
4. Press `2` to focus Staging panel
5. Press `3` to focus Branches panel
6. Press `4` to focus Log panel
7. Use arrow keys to navigate within panels
8. Press `?` to see all keybindings

### Exercise 2: Stage and Commit Changes
**Goal:** Master the basic commit workflow

1. Create a test file: `echo "test" > test.txt`
2. Open lazygit and verify it appears in Files panel
3. Press `Space` to stage the file
4. Verify it moves to Staging panel
5. Press `c` to open commit dialog
6. Type a commit message: "feat: add test file"
7. Press `Enter` to commit
8. View your commit in the Log panel (press `4`)

### Exercise 3: Unstage and Discard Changes
**Goal:** Learn to undo staging and discard unwanted changes

1. Make multiple changes: `echo "change1" >> test.txt && echo "change2" > test2.txt`
2. In Files panel, press `Space` to stage test.txt
3. Press `d` while selecting test2.txt to discard it
4. Verify test2.txt is gone from both panels
5. In Staging panel, press `Space` on test.txt to unstage it
6. Notice it moved back to Files panel

### Exercise 4: Amend Your Last Commit
**Goal:** Fix the last commit without creating a new one

1. Make a small change: `echo "oops" >> test.txt`
2. Stage it: `Space`
3. Press `c` to commit
4. Instead of typing a message, press `Ctrl+o` (or check help with `?`)
5. Amend the last commit: Look for "Amend commit" option
6. Verify the change was added to the previous commit in Log

### Exercise 5: Work with Branches
**Goal:** Create, switch, and delete branches

1. In Branches panel (press `3`), press `c` to create a branch
2. Name it: `feature/test-branch`
3. Verify it's now the active branch (highlighted)
4. Make a commit: Create a file and stage/commit it
5. Press `c` again to create another branch: `feature/another`
6. Switch back to `feature/test-branch` by pressing `Enter`
7. Delete `feature/another` by pressing `d` while selecting it

### Exercise 6: View Commit Details
**Goal:** Inspect individual commits

1. Press `4` to go to Log panel
2. Use arrow keys to select different commits
3. Press `Space` or `Enter` to see full commit details
4. View the diff of the commit
5. Press `Esc` to close the detail view

### Exercise 7: Rebase Interactively
**Goal:** Squash or reorder commits

1. Make 3 test commits with different messages
2. In Log panel, select the commit you want to rebase from
3. Press `r` to start rebase
4. In the interactive rebase menu:
   - Press `p` (pick) to keep a commit as-is
   - Press `s` (squash) to combine with previous commit
   - Press `r` (reword) to change the message
5. Complete the rebase
6. View the updated log

### Exercise 8: Stash Changes
**Goal:** Save work without committing

1. Make some changes but don't stage them
2. Press `z` to stash
3. Verify changes are gone from Files panel
4. Make different changes to test the stash is working
5. Press `z` again to access stash menu
6. Select your stashed changes and press `g` (pop/apply)
7. Your stashed changes should return

### Exercise 9: Merge Branches
**Goal:** Combine branches with automatic merges

1. Create branch `feature/branch-a` with a commit
2. Switch to `main` or `master`
3. Create branch `feature/branch-b` with a different commit
4. Switch back to `feature/branch-a`
5. Press `m` to merge, select `feature/branch-b`
6. Verify the merge commit appears in the log

### Exercise 10: Resolve Merge Conflicts (Bonus)
**Goal:** Handle merge conflicts when they occur

1. Create branch `conflict-test` from main
2. Edit the same line in a file and commit
3. Switch back to main and edit the same line differently
4. Attempt to merge `conflict-test`
5. You'll see a conflict in the Files panel
6. Press `e` to open the conflicted file in your editor
7. Manually resolve the conflict (look for `<<<<<<`, `======`, `>>>>>>`)
8. Save, stage the file, and commit the merge

---

## Lazygit Cheatsheet

### Navigation & UI

| Key | Action |
|-----|--------|
| `1-4` | Focus Files, Staging, Branches, or Log panel |
| `↑↓←→` | Navigate within panels |
| `h/j/k/l` | Vi-style navigation (if enabled) |
| `PageUp/PageDown` | Scroll up/down in current panel |
| `?` | Show all keybindings |
| `q` | Quit lazygit |
| `Ctrl+c` | Quit lazygit |

### Files & Staging

| Key | Action |
|-----|--------|
| `Space` | Toggle stage/unstage file |
| `a` | Stage all files |
| `d` | Discard changes to file |
| `o` | Open file in editor |
| `e` | Edit file inline (view diff) |
| `c` | Commit staged changes |
| `A` | Amend last commit |
| `w` | Commit with no verification |
| `W` | Amend commit with no verification |

### Commits & History

| Key | Action |
|-----|--------|
| `c` | Create new commit |
| `A` | Amend last commit (don't change message) |
| `r` | Reword last commit (change message only) |
| `R` | Rebase interactively |
| `d` | Delete commit |
| `g` | Reset to this commit (soft) |
| `G` | Reset to this commit (hard) |
| `Space` | Show commit details/diff |
| `Enter` | Show commit details in full view |
| `y` | Copy commit hash to clipboard |
| `Y` | Copy commit message to clipboard |
| `t` | Create a tag on this commit |

### Branches

| Key | Action |
|-----|--------|
| `c` | Create new branch |
| `d` | Delete branch |
| `Space/Enter` | Checkout (switch to) branch |
| `r` | Rename branch |
| `m` | Merge selected branch into current branch |
| `T` | Create tag |
| `F` | Force push branch |
| `f` | Fetch from remote |

### Stash

| Key | Action |
|-----|--------|
| `z` | Open stash menu |
| `g` | Pop/apply stash (removes from stash) |
| `Space` | View stash contents |
| `d` | Delete stash |

### Search & Filter

| Key | Action |
|-----|--------|
| `/` | Search commits by message |
| `Ctrl+f` | Filter branches |
| `Ctrl+s` | Search for text in diffs |

### Remote Operations

| Key | Action |
|-----|--------|
| `f` | Fetch from remote |
| `p` | Push to remote |
| `P` | Pull from remote (fetch + merge) |
| `u` | Set upstream branch |
| `F` | Force push |

### Interactive Rebase

When in rebase mode (press `r` on a commit):

| Key | Action |
|-----|--------|
| `p` | Pick - use commit as-is |
| `r` | Reword - change commit message |
| `s` | Squash - combine with previous commit |
| `f` | Fixup - combine, discard message |
| `x` | Execute - run shell command |
| `d` | Delete - remove commit |
| `Enter` | Confirm rebase |
| `Esc` | Cancel rebase |

### Diff & Viewing

| Key | Action |
|-----|--------|
| `Space` | Show diff of selected item |
| `Tab` | Toggle diff view (split/unified) |
| `e` | Edit file in external editor |
| `o` | Open file in default application |
| `Ctrl+u` | Scroll diff up |
| `Ctrl+d` | Scroll diff down |

### Common Workflows

#### Fast Workflow: Create, Stage, Commit
```
1. Make changes in your editor
2. lazygit
3. Space (stage all or individual files)
4. c (commit)
5. Type message, press Enter
6. q (quit)
```

#### Fix Last Commit
```
1. Make changes to files
2. lazygit
3. Stage changes: Space
4. A (amend last commit)
5. No message prompt appears (uses existing message)
6. q (quit)
```

#### Interactive Rebase to Clean Up
```
1. Log panel: 4
2. Select commit before ones to rebase
3. r (rebase interactive)
4. Squash, reword, or delete commits as needed
5. Confirm rebase
```

#### Create & Switch Branch
```
1. Branches panel: 3
2. c (create new branch)
3. Type branch name
4. Make commits as normal
5. Space to switch to other branches
```

#### Stash & Resume Later
```
1. z (stash)
2. Switch branches or do other work
3. z (open stash menu)
4. g (apply/pop stash)
```

---

## Tips & Tricks

### Performance
- If lazygit feels slow, it's usually due to large git histories
- Use `git log --oneline | wc -l` to check your history size
- Consider shallow cloning for large repos: `git clone --depth 1`

### Best Practices
1. **Make small, focused commits** - easier to review and rebase
2. **Use descriptive commit messages** - helps when reviewing history
3. **Amend instead of new commits** - for fixing typos or small changes
4. **Rebase before pushing** - clean up local commits before sharing
5. **Stash work in progress** - if you need to switch context quickly

### Keyboard Muscle Memory
- `Space` = stage/unstage (most used key)
- `c` = commit
- `3` = branches panel
- `4` = log panel
- `d` = discard/delete (use carefully!)

### Color & Appearance
- The default theme uses Git's configured colors
- Changes are color-coded: Green (staged), Red (unstaged), Yellow (untracked)
- Active branch is highlighted in the Branches panel

### When You Make a Mistake
- Press `Ctrl+z` to undo the last git operation (if enabled)
- Use the Log panel to find old commits and reset to them
- `g` = soft reset (keeps changes), `G` = hard reset (loses changes)

