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




### Configure Iterm

iTerm is the terminal of choice as it is far superior to any other terminal out there.
In order to configure the terminal to reuse the committed preferences, the following
commands need to be run.

###### Specify the preferences directory

```sh
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/plist/"
```

###### Use the custom preferences in the directory

```sh
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
```

## Other

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

### Adding a submodule

```sh
git submodule add https://github.com/seebi/dircolors-solarized .dircolors
```
