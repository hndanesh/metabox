FIRST_PARAM=$1
PROVISION_MODE=${FIRST_PARAM:-dry-run}

# helpers
function log_info {
    MESSAGE=$1
    echo "\033[32;1m${MESSAGE}\033[0m"
}

function log_verbose {
    MESSAGE=$1
    echo "\033[37;1m${MESSAGE}\033[0m"
}

function log_warn {
    MESSAGE=$1
    echo "\033[33;1m${MESSAGE}\033[0m"
}

function log_error {
    MESSAGE=$1
    echo "\033[31;1m${MESSAGE}\033[0m"
}

function validate_exit_code
{
    CODE=$1
    MGS=$2
 
    [ $CODE -eq 0 ] && log_verbose "    Exit code is 0, continue..."
    [ $CODE -ne 0 ] && log_error "Exiting with non-zero code [$CODE] - $MGS" && exit $CODE
}

function install_tool {
    PROVISION_MODE=$1
    CMD_NAME=$2
    INSTALL_CMD=$3

    log_warn "      cmd: $INSTALL_CMD"

    if [[ $PROVISION_MODE == "--provision" ]]; then
        eval $INSTALL_CMD
        validate_exit_code $? "Failed to install $CMD_NAME"  
    else
        log_error "       [!] dry-run mode, use --provision key to install software"
    fi
}

function check_or_install {

    PROVISION_MODE=$1
    CMD_NAME=$2
    INSTALL_CMD=$3

    if ! [ -x "$(command -v $CMD_NAME)" ]; then
        # brew install?
        if [ "$CMD_NAME" != "brew" ]; then
            log_verbose "       [?] $CMD_NAME cannot be found, checking with brew..." 
            brew cask list $CMD_NAME > /dev/null 2>&1

            BREW_EXIT_CODE=$?

            if [ $BREW_EXIT_CODE -ne 0 ]; then
                log_warn "   [-] $CMD_NAME cannot be found in BREW, trying to install it..." 
                install_tool $PROVISION_MODE $CMD_NAME $INSTALL_CMD
            else
                log_info "   [+] $CMD_NAME is here, with BREW"
            fi
        else
            log_warn "   [-] $CMD_NAME cannot be found, trying to install it..." 
            install_tool $PROVISION_MODE $CMD_NAME $INSTALL_CMD
        fi
    else
        log_info "   [+] $CMD_NAME is here"
    fi
}

# main flow
log_info "Installing Metabox prerequisites with provision mode: $PROVISION_MODE"

check_or_install $PROVISION_MODE "brew" '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

check_or_install $PROVISION_MODE "git" 'brew install git'
check_or_install $PROVISION_MODE "wget" 'brew install wget'
check_or_install $PROVISION_MODE "7z" 'brew install p7zip'
check_or_install $PROVISION_MODE "iterm2" 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null ; brew install caskroom/cask/brew-cask 2> /dev/null && brew cask install iterm2'

check_or_install $PROVISION_MODE "virtualbox" 'brew install Caskroom/cask/virtualbox && brew install Caskroom/cask/virtualbox-extension-pack'

check_or_install $PROVISION_MODE "packer" 'brew install packer'
check_or_install $PROVISION_MODE "vagrant" 'brew install Caskroom/cask/vagrant'

log_info "All green? - we are good to go with metabox!"