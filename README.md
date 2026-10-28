# dotfiles

My Mac setup, managed with [Nix](https://nixos.org/) and [Home Manager](https://nix-community.github.io/home-manager/). Home Manager installs the packages, links the config files in `configs/` into `$HOME` and sets up the shell. [Devbox](https://www.jetify.com/devbox) provides the global developer tools (gh, Node, and so on) and the per-project toolchains.

## Setting up a new Mac

One command installs and configures everything. It does not sign in to anything:

```sh
curl -fsSL https://raw.githubusercontent.com/mridang/dotfiles/master/install.sh | bash
```

To run it without any prompts, for example on a fresh VM:

```sh
curl -fsSL https://raw.githubusercontent.com/mridang/dotfiles/master/install.sh | bash -s -- --yes
```

The installer checks for the Xcode command line tools, installs Nix, clones this repository to `~/dotfiles`, installs Home Manager and applies `home.nix`. If the repository is private, the raw URL above does not work without a token. Export `GH_TOKEN` and fetch the script through the GitHub API, or clone the repository first and run `./install.sh` from the checkout. The options are `--yes`, `--dir` and `--repo`.

To do it by hand instead, run `make prepare`, `make install-deps` and `make apply` from a checkout.

`make test-vm` proves the installer works: it boots a throwaway macOS VM with [Tart](https://tart.run), runs `install.sh --yes` in it over SSH, checks the tools and the shell, and deletes the VM. It needs Apple Silicon and downloads a ~20 GB image into a temporary directory the first time.

## After the install

Nothing secret is stored here, so sign in to each tool once on every new machine:

```sh
ssh-keygen -t ed25519
gh auth login
gcloud auth login
aws configure sso
docker login
atuin login --username=<USERNAME>
```

`~/.npmrc` reads the GitHub Packages token from `gh auth token` (exported as `GITHUB_TOKEN` by the zsh init) and the npm token from `NPM_TOKEN`, which you only need to export when publishing to npmjs.org. The skills repository is cloned to `~/.agents/skills` the first time `make apply` runs with GitHub access, so run `make apply` again after signing in.

## How it works

`home.nix` declares the packages, the shell (zsh, bash, starship, atuin, fzf, zoxide, direnv), a weekly Nix garbage collection and the session variables. `xdg.enable` is on, so tools that honour the XDG directories use `~/.config`, `~/.cache`, `~/.local/share` and `~/.local/state`. Everything inside `configs/` is linked into `$HOME`. Devbox's global package list is `devbox-global.json`, linked to `~/.local/share/devbox/global/default/devbox.json`.

Run `make apply` after changing `home.nix`, and `devbox global update` to update the global Devbox tools. If a new terminal is broken after applying, delete the compiled zsh cache with `rm ~/.zshrc.zwc`.

## What is not managed

Credentials, SSH keys and tool state do not belong in this repository, and `.gitignore` keeps `configs/.aws/` and the private SSH keys out. Caches and history files are left alone on purpose, and these directories are deliberately not managed, so there is no need to review them again:

- Caches and package stores: `.cache`, `.npm`, `.npm-cache`, `.pnpm-state`, `.yarn`, `.m2`, `.nuget`, `.pub-cache`, `.rustup`, `.cargo`, `.pulumi` and similar.
- Tools that pin their directory in `$HOME`: `.dart`, `.dartServer` and `.dart-tool` come from the Dart SDK and cannot be moved ([dart-lang/sdk#49166](https://github.com/dart-lang/sdk/issues/49166)).
- History files: `.zsh_history` and the other `.*_history` files; shell history is synced with Atuin.

Project tools keep their state inside the project through variables in each project's `devbox.json`, such as `GRADLE_USER_HOME`, `PUB_CACHE`, `DOTNET_CLI_HOME` and `NUGET_PACKAGES`.

## Atuin

[Atuin](https://atuin.sh) syncs shell history across machines. Register once with `atuin register --username=<USERNAME> --email=<EMAIL>`, then use `atuin login` on every other machine.

## Folder icons

```sh
fileicon set ~/Code ~/dotfiles/icons/github.icns
```

## Development

Format and lint with Devbox, and prove the installer on a clean Mac with the VM test:

```sh
devbox run format
devbox run lint
make test-vm
```

## Contributing

If you have suggestions for how this setup could be improved, or
want to report a bug, open an issue - we'd love all and any
contributions.

## License

Apache License 2.0 © 2020 Mridang Agarwalla
