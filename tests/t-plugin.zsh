#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Purpose: zsh-gem-completion contract pins. Tests cover the
#####          plugin's alias surface, the gemy() yank helper,
#####          fpath augmentation, and the completion file's
#####          documented helper functions.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/zsh-gem-completion.plugin.zsh"
    compFile="$pluginDir/src/_gem"
}

@test 'gemb expands to "gem build *.gemspec" (the canonical build idiom)' {
    # Pin: the glob *.gemspec is what makes `gemb` work without args
    # in a gem's source directory. Refactoring to `gem build` (no
    # glob) would silently break the alias for the common case.
    local body
    body=$(zsh -c "
        emulate zsh
        source '$pluginFile'
        alias gemb
    ")
    assert "$body" same_as "gemb='gem build *.gemspec'"
}

@test 'gemp expands to "gem push *.gem" (the canonical publish idiom)' {
    # Pin: matches built artifact in CWD. If the glob drops, users
    # have to type the version every push — destroys the one-keystroke
    # publish workflow.
    local body
    body=$(zsh -c "
        emulate zsh
        source '$pluginFile'
        alias gemp
    ")
    assert "$body" same_as "gemp='gem push *.gem'"
}

@test 'gemy function exists with NAME + VERSION positional args' {
    # Pin: `gemy GEM 0.0.0` -> `gem yank GEM -v 0.0.0`. The function
    # (NOT alias) form is required so $1 + $2 get re-ordered around
    # the `-v` flag. An alias can't do that.
    local body
    body=$(cat "$pluginFile")
    assert "$body" contains 'function gemy'
    assert "$body" contains 'gem yank $1 -v $2'
}

@test 'gemy is callable as a function after sourcing (NOT defined as alias)' {
    # End-to-end: confirm gemy is registered as a function (not
    # alias). `whence -w gemy` returns "gemy: function" for fns
    # and "gemy: alias" for aliases.
    local out
    out=$(zsh -c "
        emulate zsh
        source '$pluginFile' 2>/dev/null
        whence -w gemy
    ")
    assert "$out" contains 'function'
}

@test 'plugin appends src/ to fpath via \${0:h}/src (plugin-manager portable)' {
    grep -qF 'fpath=("${0:h}/src" $fpath)' "$pluginFile"
    assert $? equals 0
}

@test '_gem completion file starts with #compdef gem' {
    local first
    first=$(head -1 "$compFile")
    assert "$first" same_as '#compdef gem'
}

@test '_gem completion declares #autoload directive on line 2' {
    # Pin: required for compinit to bind once at startup.
    local second
    second=$(sed -n '2p' "$compFile")
    assert "$second" same_as '#autoload'
}

@test '_gem defines __gem_installed helper (powers `gem uninstall <tab>`)' {
    # Pin: __gem_installed wraps `gem list --local --no-versions`.
    # The --no-versions flag is critical — including versions would
    # bloat the candidate list with `name-1.0.0` style strings that
    # `gem uninstall` does not accept directly.
    local body
    body=$(cat "$compFile")
    assert "$body" contains '__gem_installed()'
    assert "$body" contains 'gem list --local --no-versions'
}

@test '_gem defines __gem_search helper backed by _retrieve_cache/_store_cache' {
    # Pin: without per-prefix caching, every `gem install <tab>`
    # round-trips to rubygems.org. The cache pair makes completion
    # tolerable.
    local body
    body=$(cat "$compFile")
    assert "$body" contains '__gem_search()'
    assert "$body" contains '_retrieve_cache'
    assert "$body" contains '_store_cache'
}

@test '_gem defines memoized __gem_search_mem helper (in-process cache layer)' {
    # Pin: __gem_search_mem additionally memoizes inside an array
    # named __gems_${PREFIX} so the same prefix completes instantly
    # within the same shell session. Removing this regresses the
    # second-tab-press from instant to disk-IO.
    local body
    body=$(cat "$compFile")
    assert "$body" contains '__gem_search_mem()'
    assert "$body" contains '__gems_${PREFIX}'
}

@test '_gem search wraps `gem search -q $PREFIX` (NOT bare `gem search`)' {
    # Pin: -q (quiet) skips the cycler animation; without it, every
    # candidate line gains a leading dot, garbling the parser.
    local body
    body=$(cat "$compFile")
    assert "$body" contains 'gem search -q $PREFIX'
}

@test '_gem search uses `read tag desc` shape for "name<space>desc" parse' {
    # Pin: rubygems search output is "<name> (version) - description".
    # Renaming the `read` vars or dropping `desc` would silently drop
    # descriptions from the completion menu.
    local body
    body=$(cat "$compFile")
    assert "$body" contains 'read tag desc'
}

@test '_gem search emits _describe -t remote-gem (the documented label)' {
    # Pin: `_describe -t LABEL` controls grouping in compsys output.
    # Refactor to bare _describe (no -t) would silently break user
    # zstyle ':completion:*:remote-gem' configurations.
    local body
    body=$(cat "$compFile")
    assert "$body" contains '_describe -t remote-gem'
}

@test 'plugin registers EXACTLY 2 gem* aliases (gemb + gemp; gemy is a fn)' {
    # Pin: keeps the alias surface narrow. Silent additions during
    # release bumps would risk shadowing gem CLI primitives.
    local count
    count=$(zsh -c "
        emulate zsh
        source '$pluginFile' 2>/dev/null
        alias | grep -cE '^(gemb|gemp|gemy)='
    ")
    # gemy is a function, not an alias — so only 2 aliases.
    assert "$count" same_as '2'
}

@test '_gem completion loads cleanly under autoload +X' {
    # End-to-end: completion file must parse and bind without error.
    local result
    result=$(zsh -c "
        emulate zsh
        fpath=('$pluginDir/src' \$fpath)
        autoload -U _gem
        autoload +X _gem && print OK || print FAIL
    " 2>&1)
    assert "$result" same_as 'OK'
}

@test 'plugin sources cleanly + makes gemy + gemb + gemp all defined' {
    # End-to-end smoke: all three public names resolve after source.
    local out
    out=$(zsh -c "
        emulate zsh
        source '$pluginFile' 2>/dev/null
        printf 'gemy:%s ' \"\$(whence -w gemy 2>/dev/null | awk '{print \$2}')\"
        printf 'gemb:%s ' \"\$(whence -w gemb 2>/dev/null | awk '{print \$2}')\"
        printf 'gemp:%s ' \"\$(whence -w gemp 2>/dev/null | awk '{print \$2}')\"
    ")
    assert "$out" contains 'gemy:function'
    assert "$out" contains 'gemb:alias'
    assert "$out" contains 'gemp:alias'
}

@test 're-sourcing the plugin is idempotent (alias count + fn count stable)' {
    local first second
    first=$(zsh -c "
        emulate zsh
        source '$pluginFile' 2>/dev/null
        echo \"\$(alias | grep -cE '^gem') \$(typeset -f gemy | wc -l)\"
    ")
    second=$(zsh -c "
        emulate zsh
        source '$pluginFile' 2>/dev/null
        source '$pluginFile' 2>/dev/null
        echo \"\$(alias | grep -cE '^gem') \$(typeset -f gemy | wc -l)\"
    ")
    assert "$first" same_as "$second"
}
