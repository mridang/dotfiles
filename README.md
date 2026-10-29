# dotfiles

> [!NOTE]
> This is a very personal, opinionated setup that I happen to keep in
> public. It is not meant to be familiar or reusable for anyone else.
> Read it for ideas if you like, but expect to change a lot before it
> suits you.

My Mac setup, managed with [Nix](https://nixos.org/) and
[Home Manager](https://nix-community.github.io/home-manager/). Home Manager
installs the command-line tools, links the config files in `configs/` into
`$HOME` and sets up the shell. [Devbox](https://www.jetify.com/devbox)
provides the global developer tools and the per-project toolchains, and a
small `install-apps` command installs the Mac apps listed in `apps.txt`.

### Why?

A lost or wiped laptop should not mean weeks of rebuilding a setup from
memory. One command takes a clean Mac to a working one, and nothing secret
is stored in the repository, so it is safe to keep in public.

## Installation

One command installs and configures everything. It does not sign in to
anything:

```sh
curl -fsSL https://raw.githubusercontent.com/mridang/dotfiles/master/install.sh | bash
```

To run it without any prompts, for example on a fresh VM:

```sh
curl -fsSL https://raw.githubusercontent.com/mridang/dotfiles/master/install.sh | bash -s -- --yes
```

The installer installs the Xcode command line tools and Nix, clones this
repository to `~/dotfiles`, applies `home.nix` with Home Manager, installs
the global Devbox tools and then installs the apps below. The options are
`--yes`, `--dir` and `--repo`. To do it by hand, run `make prepare`,
`make install-deps` and `make apply` from a checkout, and `make apps` to
install the apps.

## Apps

`install-apps` installs these by their Homebrew cask name, without
Homebrew. It prefers the vendor's PKG where one exists, falls back to the
DMG, checks each app with Gatekeeper and leaves apps that are already
installed alone, so their own updaters keep working.

| App | Installed from | After installing |
|---|---|---|
| Google Chrome | PKG | Sign in to Google to bring your profile and web apps back |
| Brave | PKG | Set up Brave Sync if you use it |
| Ghostty | DMG | Nothing |
| Docker Desktop | PKG | Open it once and approve its helper; `docker login` if needed |
| Tailscale | PKG | Open it, approve the system extension and sign in |
| Proton VPN | DMG | Sign in |
| Little Snitch | DMG | Enter the license and approve the system extension |
| Rectangle | PKG | Nothing |
| IINA | DMG | Nothing |
| Transmission | DMG | Nothing |
| IntelliJ IDEA, GoLand, PhpStorm, PyCharm, Rider, RubyMine, RustRover, WebStorm, DataSpell | DMG | Sign in with your JetBrains account and turn on Settings Sync |

Anything that needs approval in System Settings, such as a system
extension, cannot be clicked through by a script, so do those by hand.

## After the install

Nothing secret is stored here, so sign in to each command-line tool once
on every new machine:

```sh
ssh-keygen -t ed25519
gh auth login
gcloud auth login
aws configure sso
docker login
atuin login --username=<USERNAME>
```

`~/.npmrc` reads the GitHub Packages token from `gh auth token` (exported
as `GITHUB_TOKEN` by the zsh init) and the npm token from `NPM_TOKEN`, which
you only need to export when publishing to npmjs.org. The skills repository
is cloned to `~/.agents/skills` the first time `make apply` runs with GitHub
access, so run it again after signing in.

## How it works

`home.nix` declares the packages, the shell (zsh, bash, starship, atuin,
fzf, zoxide, direnv), a weekly Nix garbage collection and the session
variables. `xdg.enable` is on, so tools that honour the XDG directories use
`~/.config`, `~/.cache`, `~/.local/share` and `~/.local/state`. Everything
inside `configs/` is linked into `$HOME`. Devbox's global package list is
`devbox-global.json`, linked to
`~/.local/share/devbox/global/default/devbox.json`.

Run `make apply` after changing `home.nix`, and `devbox global update` to
update the global Devbox tools. If a new terminal is broken after applying,
delete the compiled zsh cache with `rm ~/.zshrc.zwc`.

## What is not managed

Credentials, SSH keys and tool state do not belong in this repository, and
`.gitignore` keeps `configs/.aws/` and the private SSH keys out. Caches and
history files are left alone on purpose, and these directories are
deliberately not managed, so there is no need to review them again:

- Caches and package stores: `.cache`, `.npm`, `.npm-cache`, `.pnpm-state`,
  `.yarn`, `.m2`, `.nuget`, `.pub-cache`, `.rustup`, `.cargo`, `.pulumi` and
  similar.
- Tools that pin their directory in `$HOME`: `.dart`, `.dartServer` and
  `.dart-tool` come from the Dart SDK and cannot be moved
  ([dart-lang/sdk#49166](https://github.com/dart-lang/sdk/issues/49166)).
- History files: `.zsh_history` and the other `.*_history` files; shell
  history is synced with Atuin.

Project tools keep their state inside the project through variables in each
project's `devbox.json`, such as `GRADLE_USER_HOME`, `PUB_CACHE`,
`DOTNET_CLI_HOME` and `NUGET_PACKAGES`.

## Atuin

[Atuin](https://atuin.sh) syncs shell history across machines. Register once
with `atuin register --username=<USERNAME> --email=<EMAIL>`, then use
`atuin login` on every other machine.

## Folder icons

```sh
fileicon set ~/Code ~/dotfiles/icons/github.icns
```

## Development

Format and lint with Devbox, and prove the installer on a clean Mac with
the VM test:

```sh
devbox run format
devbox run lint
make test-vm
```

The app list above is kept in step with `apps.txt`. `AGENTS.md` tells coding
agents to update it whenever an app is added or removed.

## Contributing

If you have suggestions for how this setup could be improved, or
want to report a bug, open an issue - we'd love all and any
contributions.

## License

Apache License 2.0 © 2020 Mridang Agarwalla
