#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-gem-completion — fourth-tier contracts.
#####          Pins for cache-key shape (per-PREFIX isolation), the
#####          two-tier search (mem cache + retrieve cache), gem-list
#####          backend for installed-gems, and the uninstall/update
#####          subcmd routing to the installed-only completer.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    compFile="$pluginDir/src/_gem"
}

@test 'cache key includes PREFIX so each typed prefix has its own cache' {
    # Pin: `gems_cache_file="gem_${PREFIX}_cache"` in both __gem_search
    # and __gem_search_mem. Dropping $PREFIX means all `gem install` tab
    # presses share one cache and return wrong candidates after the
    # second query.
    local count
    count=$(grep -cF 'gem_${PREFIX}_cache' "$compFile")
    assert "$count" same_as '2'
}

@test '__gem_installed populates via `gem list --local --no-versions`' {
    # Pin: the installed-gems backend is `gem list --local --no-versions`,
    # not `bundle list` or `bundle show`. Routing through bundler would
    # only see Gemfile-pinned gems and miss globally-installed ones.
    grep -qF 'gem list --local --no-versions' "$compFile"
    assert $? equals 0
}

@test 'uninstall and update both route to __gem_installed (installed-only completion)' {
    # Pin: `uninstall|update)` case routes to __gem_installed so the
    # user does not get the full remote registry on a destructive op.
    grep -qE 'uninstall\|update\)' "$compFile"
    local case_form=$?
    awk '/uninstall\|update\)/,/;;/' "$compFile" | grep -q '__gem_installed'
    local routes=$?
    assert $(( case_form + routes )) equals 0
}

@test 'install subcmd routes to __gem_search (remote registry search)' {
    # Pin: `install)` case routes to __gem_search which calls
    # `gem search -q $PREFIX`. Renaming the helper or pointing install
    # at __gem_installed would break new-gem installation tab.
    awk '/^[[:space:]]+install\)/,/;;/' "$compFile" | grep -q '__gem_search$'
    assert $? equals 0
}

@test '_1st_arguments contains both `install` and `uninstall` (canonical commands)' {
    # Pin: the top-level subcommand list is presented at `gem <TAB>`.
    # Dropping either install or uninstall breaks the most basic flows.
    grep -qE "'install:" "$compFile"
    local has_install=$?
    grep -qE "'uninstall:" "$compFile"
    local has_uninstall=$?
    assert $(( has_install + has_uninstall )) equals 0
}
