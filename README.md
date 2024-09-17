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
