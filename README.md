# dotfiles

My personal dotfiles. Feel free to for but use at your own risk. In order to begin using
these dotfiles, you must check out the repository into your home directory.

```sh
git clone git@github.com:mridang/dotfiles.git
cd dotfiles
git submodule update --init
```


### Install XCode Tools

The XCode Tools is a dependency for many packages and needs to be installed first. Do
expect a popup when running this command

```sh
sudo xcode-select --install
```



### Install Homebrew

Homebrew is the package manager of choice and needs to be installed first.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/mridang/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```




### Install Packages

All packages that have been manually installed have been listed by running
 `brew leaves`. I've used `brew bundle dump` to create the `Brewfile`. The following
command will install all necessary packages.

See https://apple.stackexchange.com/q/101090/370956

```sh
brew bundle
```



### Install Fonts

The fonts used the terminal are called Powerline fonts which need to be installed
separately. The following command will install the fonts automatically.

See https://github.com/powerline/fonts

```sh
~/fonts/install.sh
```



### Link Dotfiles

Since the dotfiles are in a separate directory, GNU Stow is used to set up all the
symlinks which prevents cluttering the home directory.

###### See the symlinks that will be set up

```sh
stow --simulate --verbose -t ~ .
```

###### Actually set up all the symlinks

```sh
stow --stow --verbose -t ~ .
```

### Restore application configuration

Most applications seem to keep the configuration in `.plist` files in the
`$HOME/Library/Preferences/` directory. This directory contains other files
too e.g. configuration for internal settings.

A selective list of applications have been chosen and their configurations
have been added to version control. This makes setting a new machine a lot
easier as we no longer need to configure these applications all over again.

```shell
stow --simulate --verbose --target=$HOME/Library/Preferences plist
```

Once you've set up the symlinks, it is recommended to run the following
command to see what non-system and non-symlinked files exist. This will
allow you to eyeball which of these should be also be version controlled.

```shell
find ~/Library/Preferences/ -maxdepth 1 -type f -name "*.plist" ! -name "*com.apple*" -name "*.*.*.plist"
```

### Configure Applications

Tailscale
Docker


## Other

##### Customise the icons

In order to customise the icon for a folder - in this case, the source-code folder - the
following command can be used to update the icon.

```
fileicon set ~/Nosto ~/dotfiles/icons/github.icns
```

#### Configure Atuin

[Atuin](https://atuin.sh) is a powerful tool that allows you to sync and manage
your shell history across devices. It provides a central repository where all
your shell commands can be stored and accessed, making it easy to sync and
retrieve your history from any device. With features like automatic syncing and
the ability to search through your shell history, Atuin helps streamline your
workflow.

To start using Atuin's sync feature, follow these steps to register and log in.

#### Register Atuin Account

To register for an Atuin account, use the following command. Replace
`<YOUR_USERNAME>` and `<YOUR_EMAIL>` with your desired username and email
address:

```bash
atuin register --username=<YOUR_USERNAME> --email=<YOUR_EMAIL>
```

This command will create an account on Atuin’s servers, and you'll be able to
start syncing your shell history.

```
$ atuin register --username=godmode --email=mridang.agarwalla@gmail.com

Registering for an Atuin Sync account
Please enter password:
Registration successful! Please make a note of your key (run 'atuin key') and keep it safe.
You will need it to log in on other devices, and we cannot help recover it if you lose it.
```

```
$ atuin key

slow potato quiz cement faith argue doll appear
```

#### Log into Atuin

Once you've registered, log in with your username by running:

```bash
atuin login --username=<USERNAME>
```

This step authenticates you, linking your local machine to your Atuin account
and enabling the synchronization of your shell history.

#### Syncing Shell History

Now that you're logged in, you can sync your shell history by using the
following command:

```bash
atuin sync
```

After running the sync command, Atuin will upload your local history to its
cloud store, and it will indicate how many records are uploaded. For example,
you may see an output like this:

```bash
$ atuin sync
Uploading 1 records to 119527b30a0476e09695470052a2a71d/history
  [00:00:00] [#################################################################################################################################################################################] 1/1 (0.0s)2/0 up/down to record store
3 in history index, but 2 in history store
Running automatic history store init...
  Import complete                                                                                                                                                                                          Re-running sync due to new records locally
Uploading 1 records to 019527a30a0476e09695470052a2a71d/history
  [00:00:00] [#################################################################################################################################################################################] 1/1 (0.0s)2/0 up/down to record store
Sync complete! 3 items in history database, force: false
```

---

##### Upgrade Homebrew

```sh
brew update
brew upgrade
brew doctor
```

##### Update Software

```sh
softwareupdate --install -a
```

##### Update all submodules

```sh
git submodule update --remote --merge
```

### Adding a submodule

```sh
git submodule add https://github.com/seebi/dircolors-solarized .dircolors
```
