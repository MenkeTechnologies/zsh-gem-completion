#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-gem-completion — third-tier surface pins:
#####          - case branches in _gem: build/install/list/uninstall/update all present
#####          - build state dispatches to _files -g "*.gemspec" (the canonical file glob)
#####          - zstyle remote-gem list-grouped is false (flat menu, not grouped)
#####          - gemy function takes exactly 2 positional args ($1 + $2)
#####          - _1st_arguments uses `verb:description` shape (NOT `verb` alone)
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/zsh-gem-completion.plugin.zsh"
    gemFile="$pluginDir/src/_gem"
}

@test 'case branches in _gem cover build/install/list/uninstall/update (the 5 hot paths)' {
    # Pin: these 5 verbs drive the gem workflow. A regression that
    # drops any branch silently loses completion for that subcommand.
    local missing="" v case_block
    # extract the case block between `case "$words[1]" in` and the matching `esac`
    case_block=$(sed -n '/^case "\$words\[1\]" in/,/^esac/p' "$gemFile")
    for v in build install list uninstall update; do
        # match a case label: optional alternation, the verb, more alternation, then )
        print -r -- "$case_block" | grep -qE "^[[:space:]]+([a-z|]*\\|)?$v(\\|[a-z|]+)?\\)" || \
            missing="$missing $v"
    done
    assert "$missing" is_empty
}

@test 'build branch dispatches to _files -g "*.gemspec" (the canonical glob)' {
    # Pin: `gem build` takes a .gemspec file. The completion MUST glob
    # *.gemspec via _files -g. Dropping the glob would silently list
    # every file in cwd as a candidate.
    grep -qE '_files -g "\*\.gemspec"' "$gemFile"
    assert $? equals 0
}

@test 'zstyle list-grouped is false for remote-gem (flat menu, not column-split)' {
    # Pin: gem search yields long flat lines; grouping them by tag would
    # collapse into unreadable columns. Pin the zstyle to keep the flat
    # form deliberate.
    grep -qE "zstyle ':completion:\*:\*:gem:\*:remote-gem' list-grouped false" "$gemFile"
    assert $? equals 0
}

@test 'gemy function takes exactly 2 positional args ($1 NAME + $2 VERSION)' {
    # Pin: `gemy GEM 0.0.0` → `gem yank GEM -v 0.0.0`. The fn body
    # MUST reference both $1 and $2; a typo using just $1 would silently
    # forget the version arg.
    grep -qE 'gem yank \$1 -v \$2' "$pluginFile"
    assert $? equals 0
}

@test '_1st_arguments uses verb:description shape (NOT bare verb)' {
    # Pin: the `verb:description` shape feeds _describe so users see
    # the description column. Dropping the description (using bare
    # `verb` strings) silently degrades discoverability.
    local count
    count=$(grep -cE "^[[:space:]]+'[a-z_-]+:[^']" "$gemFile")
    [[ "$count" -ge 10 ]]
    assert $state equals 0
}
