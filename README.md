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
npm login
npm login --scope=@mridang --registry=https://npm.pkg.github.com
```

`~/.npmrc` is not managed, because `npm login` writes the tokens into it.
The two `npm login` commands sign in to npmjs.org and to GitHub Packages
(use a GitHub token with `read:packages` as the password). The skills
repository is cloned to `~/.agents/skills` the first time `make apply` runs with GitHub
access, so run it again after signing in.

## How it works

`home.nix` declares the packages (including the GNU tools below), the shell
(zsh, bash, starship, atuin, fzf, zoxide, direnv), a weekly Nix garbage
collection and the session variables. `xdg.enable` is on, so tools that honour the XDG directories use
`~/.config`, `~/.cache`, `~/.local/share` and `~/.local/state`. Everything
inside `configs/` is linked into `$HOME`. Devbox's global package list is
`devbox-global.json`, linked to
`~/.local/share/devbox/global/default/devbox.json`.

The terminal font is JetBrains Mono Nerd Font, installed by Home Manager, so
the icons in `lsd` and the prompt render in any terminal.

Run `make apply` after changing `home.nix`. It previews the change with a
dry run, applies it and then installs and updates the global Devbox tools, so
the same command also keeps those tools current. If a new terminal is broken
after applying, delete the compiled zsh cache with `rm ~/.zshrc.zwc`.

## GNU tools

macOS ships the BSD flavour of most command-line tools, and some of them are very old: `make` is from 2006, `bash` is 3.2, and `rsync` is a rewrite that speaks an ancient protocol. Linux servers, CI runners and almost every tutorial assume the GNU versions instead. The same command can behave differently on the two, or not exist at all. `sed -i 's/a/b/' file` is the classic one: GNU `sed` is happy with it, while BSD `sed` reads `s/a/b/` as the backup suffix and fails.

This matters more now that coding agents run commands in the terminal. They mostly write GNU-flavoured commands, because that is what most of the code and documentation they learned from uses. On a stock Mac those commands fail in small, confusing ways. Rather than teach every script and every agent about the differences, this setup installs the GNU tools, so the Mac behaves like the Linux machines the code will run on.

They are installed by Home Manager, unprefixed, and `~/.nix-profile/bin` comes before `/usr/bin` on the `PATH`, so the GNU version wins in the terminal. Xcode, GUI apps and anything launched outside the shell keep using Apple's tools. To reach Apple's version on purpose, call it by full path, for example `/usr/bin/sed`. `coreutils` and `findutils` were already installed and give you GNU `ls`, `cp`, `date`, `readlink -f`, `find`, `xargs` and friends.

### Installed

| Package | Version | Replaces | Why |
|---|---|---|---|
| `gnused` | 4.9 | BSD `sed` | `sed -i` and the regex dialect behave as on Linux |
| `gawk` | 5.3.2 | one-true-awk 20200816 | Full GNU awk instead of a 2020 BSD awk |
| `gnugrep` | 3.12 | BSD grep 2.6.0 | Adds `-P` (Perl regex) and Linux option parity |
| `gnumake` | 4.4.1 | GNU Make 3.81 | 3.81 dates from 2006, and CI runs 4.x |
| `diffutils` | 3.12 | BSD `diff` and `cmp` | Same output format as Linux |
| `patch` | 2.8 | patch 2.0-12u11 (Apple) | Current GNU patch |
| `gzip` | 1.14 | Apple gzip 457 | Current GNU gzip and its `z*` helpers |
| `less` | 679 | less 581 | Current pager |
| `ed` | 1.22.2 | BSD `ed` | The GNU line editor that some scripts call |
| `which` | 2.23 | BSD `which` | GNU `which` |
| `nano` | 8.7 | Apple's old pico-based nano | `EDITOR` is nano |
| `rsync` | 3.4.1 | openrsync (protocol 29) | Real rsync 3.x, as on Linux servers |
| `screen` | 5.0.1 | screen 4.00.03 (2006) | There is a `.screenrc` in `configs/` |
| `watch` | 4.0.4 | nothing, macOS has no `watch` | Pure addition |
| `ripgrep` | 15.1.0 | nothing, macOS has no `rg` | Pure addition; agent tooling reaches for it first |

### Every command they provide

| Package | Command | Replaces | What it does |
|---|---|---|---|
| `gnused` | `sed` | BSD `sed` | Edits a stream of text with substitution scripts |
| `gawk` | `awk` | one-true-awk | Pattern scanning and text processing |
| `gawk` | `gawk` | new | The same program under its GNU name |
| `gnugrep` | `grep` | BSD `grep` | Searches text for a pattern |
| `gnugrep` | `egrep` | BSD `egrep` | `grep -E`, extended regular expressions |
| `gnugrep` | `fgrep` | BSD `fgrep` | `grep -F`, fixed strings |
| `gnumake` | `make` | `make` 3.81 | Builds targets from a Makefile |
| `diffutils` | `diff` | BSD `diff` | Shows the lines that differ between two files |
| `diffutils` | `cmp` | BSD `cmp` | Compares two files byte by byte |
| `diffutils` | `diff3` | BSD `diff3` | Compares three files |
| `diffutils` | `sdiff` | BSD `sdiff` | Side-by-side merge of two files |
| `patch` | `patch` | Apple `patch` | Applies a diff to files |
| `gzip` | `gzip` | Apple `gzip` | Compresses files |
| `gzip` | `gunzip` | Apple `gunzip` | Decompresses `.gz` files |
| `gzip` | `uncompress` | Apple `uncompress` | Decompresses old `.Z` files |
| `gzip` | `zcat` | Apple `zcat` | Prints a compressed file |
| `gzip` | `zcmp` | Apple `zcmp` | `cmp` on compressed files |
| `gzip` | `zdiff` | Apple `zdiff` | `diff` on compressed files |
| `gzip` | `zegrep` | Apple `zegrep` | `egrep` on compressed files |
| `gzip` | `zfgrep` | Apple `zfgrep` | `fgrep` on compressed files |
| `gzip` | `zgrep` | Apple `zgrep` | `grep` on compressed files |
| `gzip` | `zless` | Apple `zless` | Pages a compressed file |
| `gzip` | `zmore` | Apple `zmore` | Pages a compressed file with `more` |
| `gzip` | `znew` | Apple `znew` | Recompresses `.Z` files as `.gz` |
| `gzip` | `zforce` | Apple `zforce` | Renames gzip files to end in `.gz` |
| `gzip` | `gzexe` | Apple `gzexe` | Compresses an executable that unpacks itself |
| `less` | `less` | Apple `less` | Pages through text |
| `less` | `lessecho` | Apple `lessecho` | Expands shell metacharacters for `less` |
| `less` | `lesskey` | new | Builds a `less` key-binding file |
| `ed` | `ed` | BSD `ed` | The standard line editor |
| `ed` | `red` | new | `ed` restricted to the current directory |
| `which` | `which` | BSD `which` | Shows the full path of a command |
| `nano` | `nano` | Apple `nano` | Small terminal text editor |
| `nano` | `rnano` | new | `nano` restricted to the current directory |
| `rsync` | `rsync` | openrsync | Fast incremental file copy, local or over SSH |
| `rsync` | `rsync-ssl` | new | `rsync` over a TLS connection |
| `screen` | `screen` | `screen` 4.00.03 | Terminal multiplexer |
| `screen` | `screen-5.0.1` | new | The same program under its versioned name |
| `watch` | `watch` | new | Runs a command every few seconds and shows the output |
| `ripgrep` | `rg` | new | Fast recursive search that respects `.gitignore` |

### Not installed

These are the other packages that usually appear on "replace macOS tools with GNU" lists. They were considered and left out on purpose.

| Package | Commands it would shadow | Why not |
|---|---|---|
| `binutils` | `ar`, `nm`, `strip`, `ranlib`, `objdump`, `strings`, `c++filt`, `size` | Tested on this Mac: GNU `ar` produced an archive the Apple linker rejected, and GNU `strip` removed symbols from a Mach-O file. It breaks native builds. |
| `inetutils` | `ifconfig`, `ping`, `traceroute`, `hostname`, `whois`, `logger` and others | Tested on this Mac: `ifconfig lo0` failed with `invalid arguments`. The rest only duplicate what already works. |
| `procps` | `ps`, `top`, `sysctl` | On macOS it is an Apple-derived port, so it adds nothing. |
| `util-linux` | `cal`, `hexdump`, `logger`, `renice`, `wall`, `look`, `rev` and others | Shadows several system tools, and only `column` and `getopt` are new. |
| `gnutar` | `tar` | Apple's `bsdtar` handles macOS metadata (extended attributes, resource forks) better. |
| `parallel` | none | `moreutils` already provides a `parallel`. |
| `bashInteractive` | `bash`, `sh`, `bashbug` | Would replace `sh` and `bash` for every script that finds them on the `PATH`. The login shell is zsh. |
| `indent` | `indent` | GNU indent is a different tool from FreeBSD's `indent`, and it is rarely needed. |
| `m4`, `flex`, `bison`, `autoconf`, `automake`, `libtool`, `gettext` | `m4`, `flex`, `bison`, `lex`, `yacc`, `libtool` and others | Build-time tools. Each project's `devbox.json` should pin the ones it needs. |
| `zip`, `unzip` | `zip`, `unzip`, `zipinfo`, `funzip` and others | Same Info-ZIP versions as Apple's, so no gain. |
| `time`, `bc`, `wdiff` | `time`, `bc`, `dc` | Not needed: the shell has `time`, Apple's `bc` is current, and `wdiff` is niche. |

One trade-off remains from the existing `coreutils`: GNU `cp` and `mv` do not preserve macOS tags and extended attributes the way Apple's do.

### Further reading

- [Using GNU command line tools in macOS instead of FreeBSD tools](https://ryanparman.com/posts/2019/using-gnu-command-line-tools-in-macos-instead-of-freebsd-tools/) by Ryan Parman, the clearest write-up of why and how.
- [The long Homebrew list gist](https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da), where most of the "also install this" ideas come from.
- [Replacing macOS BSD utils with GNU coreutils](https://devedge.github.io/2026/03/14/replacing-macOS-BSD-utils-with-GNU-coreutils) for a recent take, including `rsync`.
- [Updating rsync on macOS](https://dev.to/al5ina5/updating-rsync-on-macos-so-you-re-not-stuck-with-14-year-old-software-1b5i) and [macOS Sequoia: rsync out, openrsync in](https://heise.de/-10350663) on why the bundled `rsync` is a problem.
- [macOS uses a completely outdated version of Bash](https://changelog.com/news/b01e), the reason `bash` is on the list of things to be careful with.
- [Script compatibility on macOS](https://cloudstreet-dev.github.io/macOS-and-Unix/part11-interoperability/script-compatibility.html), a concrete list of BSD and GNU differences (`sed -i`, `date -d`, `stat`, `readlink -f`, `grep -P`).
- [PostToolUse hook for BSD/GNU tool miss detection](https://agentpatterns.ai/tool-engineering/posttooluse-bsd-gnu-detection/) shows how coding agents trip over these differences on macOS.
- [JShelter issue 131](https://pagure.io/JShelter/webextension/issue/131), a real project that had to work around BSD `sed` in its build.

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
