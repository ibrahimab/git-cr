# git-cr: Interactive Git Conflict Resolver

`git-cr` is a Bash-based interactive tool for resolving Git merge conflicts **block-by-block** with syntax highlighting, previews, and undo support. It is designed to make the process of resolving complex merge conflicts easier and safer, especially for developers working in large codebases.

---

**Disclaimer:**  
This project is still in **alpha**. Unexpected bugs or edge cases may occur.  
If you encounter any issues, please open a bug report and include as much detail as possible, such as:
- What you were trying to do
- The steps to reproduce the problem
- Any error messages or output

Your feedback is greatly appreciated and will help improve the tool!

---

## Features

- **Interactive conflict resolution:** Step through each conflict block in a file, preview changes, and choose which side to keep.
- **Syntax highlighting:** Uses [`bat`](https://github.com/sharkdp/bat) for colorful, language-aware previews.
- **Undo support:** Easily undo your last resolution choice before finalizing.
- **Auto-resolve trivial conflicts:** Automatically resolves blocks where both sides are identical.
- **Safe file operations:** All changes are made in temporary files and only applied when you confirm.
- **Works in any subdirectory:** Automatically detects and operates from the repository root.
- **Supports all file types:** Handles code, config, and binary files (with plain text fallback).

---

## Installation

### Prerequisites

- **Bash** (version 4+ recommended)
- **bat** (for syntax highlighting)
- **shc** (for building a binary)
- **git** (must be installed)

### Build and Install

From the project root:

```sh
./build.sh
```

This will concatenate all modules, build a binary using `shc`, and install it to `/usr/local/bin/git-cr`.

---

## Usage

1. **Start a merge that results in conflicts:**

   ```sh
   git merge <branch>
   ```

2. **Run git-cr from anywhere in your repo:**

   ```sh
   git-cr
   ```

3. **Follow the interactive prompts:**
   - View each conflict block with context and syntax highlighting.
   - Choose to keep "ours" (current branch), "theirs" (incoming branch), or skip/undo.
   - Preview your choice before applying.
   - Undo if you change your mind.
   - Cancel at any time to abort without saving changes.

4. **After all conflicts are resolved:**
   - `git-cr` will stage the resolved files.
   - You can now commit the merge as usual.

---

## Options & Controls

- **(c)** Keep current branch ("ours")
- **(i)** Keep incoming branch ("theirs")
- **(p)** Preview the block before applying
- **(u)** Undo last resolution
- **(s)** Skip this block
- **(q)** Cancel and abort (no changes saved)

---

## How It Works

- Detects conflicted files using `git diff --name-only --diff-filter=U`.
- Changes to the repository root for all file operations.
- Processes each conflict block interactively.
- Uses temporary files for all edits; only overwrites the original file when you confirm.
- Stages resolved files with `git add`.

---

## Troubleshooting

- **bat errors:** If you see `[bat error]: unknown syntax`, make sure your file extension is supported by `bat`. Unknown types will be shown as plain text.
- **Permission errors:** You may need `sudo` for installation to `/usr/local/bin`.
- **Missing dependencies:** Install with:
  ```sh
  sudo apt-get install bat shc
  ```

---

## Development

- Modular Bash scripts: `colors.sh`, `preview.sh`, `resolve.sh`, `context.sh`, `options.sh`, `block.sh`, `run.sh`, `main.sh`.
- All file operations use the repo root for safety.
- After the script is done, it will safely return you to your `pwd`.
- Easy to extend for new file types or custom workflows.

---

## License

MIT License

---

## Credits

- [bat](https://github.com/sharkdp/bat) for syntax highlighting

---

## Contributing

Pull requests and issues are welcome! Please open an issue for bugs or feature requests.