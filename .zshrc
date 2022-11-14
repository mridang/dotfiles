# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

source $ZSH/oh-my-zsh.sh
source ${HOME}/antigen/antigen.zsh

antigen init $HOME/.antigenrc


DEFAULT_USER="mridang"
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status virtualenv nvm root_indicator background_jobs history time)
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S %d/%m/%Y}"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/mridang/.sdkman"
[[ -s "/Users/mridang/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/mridang/.sdkman/bin/sdkman-init.sh"


#export PYENV_ROOT="$HOME/.pyenv"
#export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init --path)"
#eval "$(pyenv init -)"
