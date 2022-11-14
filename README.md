# dotfiles
My personal dotfies. Feel free to for but use at your own risk.


## Install Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/mridang/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```


## Brew Packages

All packages that have been manually installed have been listed by running
 `brew leaves`. I've used `brew bundle dump` to create the `Brewfile`.

https://apple.stackexchange.com/q/101090/370956

Install everything from the Brewfile by running `brew bundle`


## Fonts

The font I'm using is the Powerline pactched-fonts.

https://github.com/powerline/fonts

Install everything from Powerline by running `~/fonts/install.sh`


## Link Dotfiles


```sh
stow --simulate --verbose -t ~ .
```


```sh
stow --stow --verbose -t ~ .
```



## Configure Iterm

##### Specify the preferences directory

```sh
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/plist/"
```

##### Tell iTerm2 to use the custom preferences in the directory

```sh
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
```

## Other

#### Adding a submodule

```sh
git submodule add https://github.com/seebi/dircolors-solarized .dircolors
```
