#!/bin/bash

# Installs the zsh shell and adds the configuration to .zshrc
# 
# 1) Checks to see if Homebrew is installed, and if not, installs it
# 2) Installs zsh, and changes the default shell to zsh
# 3) Installs the configuration and reloads the shell

run() {
    $1
    local return_value="$?"

    if [ "$return_value" -ne "0" ]; then
        exit $return_value
    fi
}

check_shell() {
    local current_shell=$(echo $SHELL)
    local zsh_path=$(which zsh)

    if [  "$current_shell" = "$zsh_path" ]; then
        return 0
    else
        return 1
    fi
}

check_homebrew() {
    printf "Checking for homebrew... "

    # Checks if Homebrew is installed at all
    local output=$(brew --version 2>/dev/null)

    if [ -z "$output" ]; then
        echo "failed."
        echo "Installing homebrew."

        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

        if [ "$?" -ne "0" ]; then
            echo "Homebrew installation failed. Please check the error message and try again."
            return 1
        fi
    else
        echo "ok."
    fi
}

check_zsh() {
    printf "Checking for zsh... "

    # Checks if zsh is installed at all
    local output=$(zsh --version 2>/dev/null)

    if [ -z "$output" ]; then
        echo "failed."
        echo "Installing zsh."

        brew install zsh

        if [ "$?" -ne "0" ]; then
            echo "zsh installation failed. Check the error message and try again."
            return 2
        fi
    else
        # zsh is installed, but we should make sure that it
        # is the correct version (from homebrew)

        local brew_prefix=$(brew --prefix)
        local zsh_bash=$(which zsh)

        if [[ ! "$zsh_bash" =~ "$brew_prefix" ]]; then
            echo "failed!"
            echo "Installing zsh."

            brew install zsh

            if [ "$?" -ne "0" ]; then
                echo "zsh installation failed. Check the error message and try again."
                return 3
            fi
        else
            echo "ok."
        fi  
    fi
}

change_shell() {
    echo "Changing default shell to zsh."

    local shell_location=$(which zsh)

    grep -Fxq "$shell_location" /etc/shells

    if [ "$?" -ne "0" ]; then
        echo "Homebrew zsh shell location ($shell_location) is not in /etc/shells. Appending."

        echo "$shell_location" | sudo tee -a /etc/shells > /dev/null
    fi

    chsh -s "$shell_location"

    if [ "$?" -ne "0" ]; then
        echo "Shell changing failed." 
        return 4
    else
        echo "Shell changing succeeded."
    fi
}

install_config() {
    echo "Installing .zshrc config to home directory."

    if [ ! -f "~/.zshrc" ]; then
        cp ./.zshrc ~/.zshrc
    else
        mv ~/.zshrc ~/.zshrc.bak
        cp ./.zshrc ~/.zshrc
    fi
}

check_shell

if [ "$?" -ne "0" ]; then
    run check_homebrew
    run check_zsh
    run change_shell
    run install_config
else
    echo "zsh is properly installed. Installing configuration."
    run install_config
fi