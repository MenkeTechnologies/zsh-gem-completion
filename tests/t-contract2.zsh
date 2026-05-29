#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-gem-completion — second-tier contract pins.
#####          Cover surfaces not pinned by t-plugin/t-aliases:
#####          gemy positional contract, _gem subcommand-route
#####          structure, _1st_arguments static list contents,
#####          and inline-completion style (no trailing _gem "$@").
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/zsh-gem-completion.plugin.zsh"
    compFile="$pluginDir/src/_gem"
}

@test 'gemy invokes gem yank with -v in between (positional reorder)' {
    # Pin: the function body MUST be `gem yank $1 -v $2`. Reordering
    # to `gem yank $2 -v $1` would silently yank the wrong version.
    grep -qF 'gem yank $1 -v $2' "$pluginFile"
    assert $? equals 0
}

@test '_gem is inline-style completion (NOT autoload + bare _gem "$@" at end)' {
    # Pin: the completion is structured as #compdef + #autoload header
    # + body running on autoload. The last meaningful line is `esac`
    # closing the routing case. A refactor that appends `_gem "$@"`
    # would change the autoload semantics.
    local last
    last=$(grep -vE '^\s*$' "$compFile" | tail -1)
    assert "$last" same_as 'esac'
}

@test '_1st_arguments static list includes install/uninstall/update/search/list/cleanup' {
    # Pin: the canonical gem CLI subcommand set. Dropping any from
    # this static list silently breaks `gem <tab>` for that verb.
    local body
    body=$(cat "$compFile")
    assert "$body" contains 'install:'
    assert "$body" contains 'uninstall:'
    assert "$body" contains 'update:'
    assert "$body" contains 'search:'
    assert "$body" contains 'list:'
    assert "$body" contains 'cleanup:'
}

@test '_gem subcommand router dispatches via case on $words[1]' {
    # Pin: _gem uses _arguments with state and routes via words[1]
    # (which inside the state context is the subcommand). The router
    # case is what makes install vs uninstall vs update behave
    # differently. Pin the structure shape.
    grep -qE 'case "\$words\[1\]"' "$compFile"
    assert $? equals 0
}

@test '_gem uninstall + update share __gem_installed source (DRY pin)' {
    # Pin: both completions need installed-gem candidates. The router
    # MUST share the call to __gem_installed. Renaming/duplicating
    # would diverge their candidate sets.
    grep -qE 'uninstall\|update\)' "$compFile"
    assert $? equals 0
    grep -qE '__gem_installed' "$compFile"
    assert $? equals 0
}
