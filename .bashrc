# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

################################################
################################################
################ EDIT BELOW ####################
################################################
################################################

#####################################
# Text colours for terminal happiness
JWSL_BLACK="\033[0;30m"
JWSL_RED="\033[1;31m"
JWSL_GREEN="\033[1;32m"
JWSL_YELLOW="\033[1;33m"
JWSL_BLUE="\033[1;34m"
JWSL_MAGENTA="\033[1;35m"
JWSL_CYAN="\033[1;36m"
JWSL_WHITE="\033[1;37m"
JWSL_ORANGE="\033[38;5;208m"
JWSL_PINK="\033[38;5;213m"
# Font style variables
JWSL_BOLD="\033[1m"
JWSL_DIM="\033[2m"
JWSL_ITALIC="\033[3m"
JWSL_UNDERLINE="\033[4m"
JWSL_BLINK="\033[5m"
JWSL_REVERSE="\033[7m"
JWSL_STRIKETHROUGH="\033[9m"
JWSL_RESET="\033[0m"

#####################
# Custom help command
function display_commands {
    awk -v yellow="$JWSL_YELLOW" -v blue="$JWSL_CYAN" -v bold="$JWSL_BOLD" -v reset="$JWSL_RESET" '
    BEGIN {
        in_section = 0;
        row_count = 0;
        max_cmd = length("Command");
        max_desc = length("Description");
    }
    /^# Custom Command Aliases$/ { in_section = 1; next }
    /^# End Custom Command Aliases$/ { in_section = 0 }
    in_section {
        if ($0 ~ /^#/) {
            c = $0; sub(/^#[ ]?/, "", c); last_comment = c
        } else if ($0 ~ /^alias/) {
            if ($0 ~ /# ignore[ \t]*$/) next;
            split($0, parts, "=");
            cmd = substr(parts[1], 7); gsub(/^[ \t]+|[ \t]+$/, "", cmd);
            desc = last_comment;
            last_comment = "";
            row_count++;
            cmds[row_count] = cmd;
            descs[row_count] = desc;
            if (length(cmd) > max_cmd) max_cmd = length(cmd);
            if (length(desc) > max_desc) max_desc = length(desc);
        }
    }
    END {
        printf "%s%s%-*s%s", blue, bold, max_cmd+1, "Command", reset;
        printf "%s%s%-*s%s\n", blue, bold, max_desc+1, "Description", reset;
        for (i=1; i<=row_count; i++) {
            printf "%s%-*s%s", yellow, max_cmd+1, cmds[i], reset;
            printf "%s%-*s%s\n", blue, max_desc+1, descs[i], reset;
        }
    }
    ' ~/.bashrc
}

###############################################
# Check & install standard development packages
REQUIRED_PKGS=("curl" "git" "man" "python3")

for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        echo "$pkg is not installed."
        read -p "Do you want to install $pkg? [y/N] " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            sudo apt install -y "$pkg"
        fi
    fi
done

##################################
# Setup Python virtual environment
VENV_DIR="/home/jasper/debian_python_env"

if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

export PATH="$VENV_DIR/bin:$PATH"

###############################
# Install Go
SKIP_GO_INSTALL=0
for arg in "$@"; do
    if [[ "$arg" == "--skipGoInstall" ]]; then
        SKIP_GO_INSTALL=1
        break
    fi
done

if [[ $SKIP_GO_INSTALL -eq 0 ]] && [[ -f ./install-golang.sh ]] && [ ! -d /usr/local/go ]; then
    read -p "Go is not installed. Would you like to run install-golang.sh to install Go? [y/N] " yn
    case $yn in
    [Yy]*)
        ./install-golang.sh
        ;;
    *)
        echo "Skipping Go installation."
        ;;
    esac

    # Ensure Go is in path
    GO_BIN_DIR="/usr/lib/go-*/bin"
    if [[ ":$PATH:" != *":$GO_BIN_DIR:"* ]]; then
        export PATH="$GO_BIN_DIR:$PATH"
    fi
fi

########################################
# Custom Functions, Commands and Aliases

# Load .env file
if [ -f "$HOME/jasper-wsl/jwsl.env" ]; then
    source "$HOME/jasper-wsl/jwsl.env"
    _addConfigDirFlags="--config $HUGO_PROJECT_CONFIG_PATH/hugo.toml --configDir $HUGO_PROJECT_CONFIG_PATH"
else
    echo "Error: jwsl.env not found. Please follow README.md Installation, Step 2 to create it."
    exit 1
fi

# Install debian package function
_installDebianPackage() {
    if [ -z "$1" ]; then
        echo "Usage: installdeb <package.deb>"
        return 1
    fi
    sudo dpkg -i "$1" && sudo apt-get install -f
}

# Find and view env files
_viewLocalEnvFiles() {
    search_dir="$PWD"
    search_response_str="Checking for .env files in the current directory and subdirectories..."
    if [ -n "$1" ]; then
        search_dir="$1"
        search_response_str="Checking for .env files in: $1 and subdirectories..."
    fi

    _colourPrint "$search_response_str" JWSL_YELLOW

    local env_files
    env_files=$(find $search_dir -type f -name '*.env' 2>/dev/null)
    if [[ -z "$env_files" ]]; then
        _colourPrint "No .env files found." JWSL_RED
        return 0
    fi
    _colourPrint "Found the following .env files:" JWSL_CYAN
    for file in $env_files; do
        _colourPrint "$file" JWSL_CYAN
        _colourPrint "====================" JWSL_CYAN
        cat "$file"
        _colourPrint "\n====================\n" JWSL_CYAN
    done
}

_colourPrint() {
    # Usage: _colourPrint "Text to print" JWSL_YELLOW [JWSL_BOLD ...]
    if [[ "$#" -eq 0 ]]; then
        echo "No arguments provided. Use -h or --help for usage information."
        return 1
    fi
    
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "\nUsage: _colourPrint \"Text to print\" COLOUR [STYLE ...]"
        echo -e "Prints the given text in the specified colour and optional font styles."
        echo -e ""
        echo -e "Arguments:"
        echo -e "  COLOUR   One of your global colour variables (e.g., JWSL_RED, JWSL_YELLOW, JWSL_BLUE, etc.)"
        echo -e "  STYLE    (Optional) One or more style variables (e.g., JWSL_BOLD, JWSL_ITALIC, JWSL_UNDERLINE, etc.)"
        echo -e ""
        echo -e "Examples:"
        echo -e "  _colourPrint \"Hello\" JWSL_GREEN"
        _colourPrint "Hello" JWSL_GREEN
        echo -e "  _colourPrint \"Disabled\" JWSL_YELLOW JWSL_BOLD"
        _colourPrint "Disabled" JWSL_YELLOW JWSL_STRIKETHROUGH
        return 0
    fi
    local text="$1"
    shift
    local color_args=( $@ )
    local color_seq=""
    # If multiple colors/styles, first is color, rest are styles
    if [ ${#color_args[@]} -gt 1 ]; then
        color_seq="${!color_args[0]}"
        for ((i=1; i<${#color_args[@]}; i++)); do
            color_seq+="${!color_args[i]}"
        done
    else
        color_seq="${!color_args}" # Single color/style
    fi
    # Print the colored text with reset
    echo -e "${color_seq}${text}${JWSL_RESET}"
}

########################
# Custom Command Aliases

# Display all available custom commands with descriptions
alias helpc='display_commands'
# Show success message after reloading .bashrc
alias bashhappy='echo ".bashrc reloaded ✅"' # ignore
# Quick reload of .bashrc (rs = reload shell)
alias rs="source ~/.bashrc && bashhappy"
# Clear terminal screen
alias ct='clear'
# Extract tar.gz files easily, usage: untar file.tar.gz
alias untar='tar -xvzf'
# Edit .bashrc and quick reload
alias editbash='vim ~/.bashrc && rs'
# Install .deb package and fix dependencies, usage: installdeb <package.deb>
alias installdeb='_installDebianPackage'
# Clean Hugo's cache and remove generated files
alias hclean="hugo --gc --cleanDestinationDir ${_addConfigDirFlags}"
# Build hugo site for production (clean project, build)
alias hbuild="hclean && hugo build ${_addConfigDirFlags}"
# Run hugo server in dev env (clean project, serve no cache and draft content included)
alias hsrv="hclean && hugo server --disableFastRender --buildDrafts --ignoreCache --noHTTPCache --renderStaticToDisk ${_addConfigDirFlags}"
# Run hugo server in dev env for debugging (clean project, panic on warning and use log level debug)
alias hsrvd="hclean && hsrv --logLevel debug --panicOnWarning ${_addConfigDirFlags}"
# Deploy the website to production server
alias deployWebserver="~/suzi-personal/deploy-to-spaceship.sh"
# Deletes all files in temporary (sub)directory
alias jclean='rm -vf /tmp/jwsl/*'
# View all .env files in the current directory and subdirectories
alias viewenv='_viewLocalEnvFiles'
# Print in colour
alias printc='_colourPrint'

# End Custom Command Aliases
# Do not remove the above line
##############################

##################################
# Configure global git credentials
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"