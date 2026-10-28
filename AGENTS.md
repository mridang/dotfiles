# Agent instructions

Personal macOS setup managed with Nix, Home Manager and Devbox. `home.nix` declares the packages and shell, `configs/` is linked into `$HOME`, `apps.txt` lists the apps that `install-apps` installs, and `install.sh` sets up a new Mac.

## Things to know before editing

- Files in `configs/` are symlinked into `$HOME` with `mkOutOfStoreSymlink`, so editing one changes the live file on the machine at once. `~/.npmrc`, `~/.gitconfig` and the rest are those files.
- Never commit credentials, tokens or keys. `configs/.aws/` and the private SSH keys are ignored on purpose, and `.npmrc` reads its tokens from environment variables.
- Do not run `make apply` or `home-manager switch` on the user's machine unless asked. Check a change with `home-manager build --file home.nix` instead.
- `install-apps.sh` has no shebang on purpose: `home.nix` wraps it with `writeShellApplication`, which adds one and runs ShellCheck at build time.

## Commands

- `devbox run format` applies alejandra and `shfmt -i 2`. `devbox run lint` runs statix, deadnix and ShellCheck with warnings as errors. Both must pass.
- `make test-vm` boots a clean macOS VM with Tart and runs the installer in it. It needs Apple Silicon, downloads a ~20 GB image the first time and takes a while, so run it only when `install.sh`, `install-apps.sh`, `apps.txt` or `home.nix` change.

## Conventions

- The default branch is `master`. Branches are named `<type>/<kebab-case-description>`.
- Commit messages are conventional commits with no trailers and no attribution, and body lines wrapped under 100 characters.
- Apps in `apps.txt` are Homebrew cask names. Add `pkg=<url>` only where the vendor's PKG is not in Homebrew's data.
