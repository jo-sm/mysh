setopt PROMPT_SUBST

alias npm-exec='PATH=$(npm bin):$PATH'
alias darth-vader="git push -f"
alias p="git push"
alias pu='git push -u origin $(git symbolic-ref --short HEAD)'

red='\001\033[0;31m\002'
yellow='\001\033[0;33m\002'
green='\001\033[0;32m\002'
orange='\001\033[38;5;208m\002'
blue='\001\033[0;34m\002'
pink='\001\033[0;35m\002'
NC='\001\033[0m\002'

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
eval "$(rbenv init -)"
eval "$(pyenv init -)"

function is_git {
  if git rev-parse --is-inside-work-tree 2>/dev/null; then
    return 1
  else
    return 0
  fi
}

function stuff {
  if [ $(is_git) ]; then
    git_dir=$(git rev-parse --git-dir 2>/dev/null)
    has_commit=$(git rev-parse --short HEAD 2>/dev/null)

    if [ -z $has_commit ]; then
      echo -en " [${blue}init${NC}] > "
      return
    fi

    git_branch=$(git rev-parse --abbrev-ref HEAD)
    git_commit=$(git rev-parse HEAD | cut -c1-8)

    if [[ "$git_branch" == "HEAD" ]]; then
      echo -en " [${blue}"
      echo -n ${git_commit}
      echo -en "${NC}] > "
      return
    fi

    # TODO: Update this to use something that doesn't use git-status, as it is slow on large
    # status differences
    IFS=$'\n' read -rd '' -A test_arr <<< "$(git status -s 2>/dev/null | cut -c1-2)"
    modified=false
    staged=false

    test_arr=("${(s'')test_arr}")

    if [[ "${test_arr[1]}" != " " ]] && [[ "${test_arr[1]}" != "?" ]]; then
      staged=true
    fi

    if [[ "${test_arr[2]}" != " " ]] && [[ "${test_arr[2]}" != "?" ]]; then
      modified=true
    fi

    echo "modified: '${modified}; staged: ${staged}"

    echo -n " ["
    if [[ "$modified" == false ]] && [[ "$staged" == false ]]; then
      echo -en "${green}"
    elif [[ "$modified" == true ]] && [[ "$staged" == false ]]; then
      echo -en "${red}"
    elif [[ "$modified" == true ]] && [[ "$staged" == true ]]; then
      echo -en "${orange}"
    elif [[ "$modified" == false ]] && [[ "$staged" == true ]]; then
      echo -en "${yellow}"
    fi
    echo -en "$(git rev-parse --abbrev-ref HEAD)${NC}]"
  fi

  echo " > "
}

determine_git() {
  original_buffer="$BUFFER"
  command_arr=("${(s' ')BUFFER}")

  # only do this if we're in a git directory
  if [ $(is_git) ]; then
    # prefer the original command first, if there's a dash in front
    if [[ "${command_arr[1]:0:1}" == "-" ]]; then
      actual_command=${command_arr[1]:1:${#command_arr[1]}-1}
      if type $actual_command 1>/dev/null 2>/dev/null; then
        BUFFER="$actual_command ${command_arr[@]:1}"
      fi
    fi

    # Test if manual exists
    man "git-${command_arr[1]}" > /dev/null 2>&1

    if [[ "$?" -eq "0" ]]; then
      BUFFER="git ${command_arr[@]}"
    fi
  fi

  zle accept-line
}

zle -N determine_git_widget determine_git
bindkey '^J' determine_git_widget
bindkey '^M' determine_git_widget

export PS1="@ %.\$(stuff)"
