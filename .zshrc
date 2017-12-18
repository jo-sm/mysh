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

function is_git {
  if git rev-parse --is-inside-work-tree 2>/dev/null; then
    return 1
  else
    return 0
  fi
}

function check_git {
  # remove newline from kill
  if [ -e "/tmp/rangit" ]; then
    rm /tmp/rangit
    echo -ne "\r\033[1A"
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

    if [ "$git_branch" == "HEAD" ]; then
      echo -en " [${blue}"
      echo -n ${git_commit}
      echo -en "${NC}] > "
      return
    fi

    # TODO: Update this to use something that doesn't use git-status, as it is slow on large
    # status differences
    IFS=$'\n' read -rd '' -a test_arr <<< "$(git status -s 2>/dev/null | cut -c1-2)"
    modified=false
    staged=false

    if [ -n "$test_arr" ]; then
      for i in "${test_arr[@]}"
      do
        if [ "${i:0:1}" != " " ] && [ "${i:0:1}" != "?" ]; then
          staged=true
        fi

        if [ "${i:1:1}" != " " ] && [ "${i:1:1}" != "?" ]; then
          modified=true
        fi
      done
    fi

    echo -n " ["
    if [ "$modified" = false ] && [ "$staged" = false ]; then
      echo -en "${green}"
    elif [ "$modified" = true ] && [ "$staged" = false ]; then
      echo -en "${red}"
    elif [ "$modified" = true ] && [ "$staged" = true ]; then
      echo -en "${orange}"
    elif [ "$modified" = false ] && [ "$staged" = true ]; then
      echo -en "${yellow}"
    fi
    echo -en "$(git rev-parse --abbrev-ref HEAD)${NC}]"
  fi

  echo " > "
}

export PS1="\$(check_git)@ %.\$(stuff)"