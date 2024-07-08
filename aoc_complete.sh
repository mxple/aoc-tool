_aoc_complete() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="run create sumbit init-year init-master config-gen edit info-dump"

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )

    return 0
}

complete -F _aoc_complete aoc
