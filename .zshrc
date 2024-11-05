# If you ever need to debug the scripts, simply enable this flag to print
# all executing commands to the console.
# set -x

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

source $ZSH/oh-my-zsh.sh
source ${HOME}/antigen/antigen.zsh
source ${HOME}/dotfiles/iterm/iterm-shell-integration.zsh

antigen init $HOME/.antigenrc

DEFAULT_USER="mridang"
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status virtualenv root_indicator background_jobs history time)
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S %d/%m/%Y}"