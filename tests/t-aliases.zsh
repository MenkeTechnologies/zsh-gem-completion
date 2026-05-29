#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Purpose: alias-presence pins for zsh-gem-completion. Registers
#####          2 gem* aliases for the rubygems CLI: build + push.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
}

@test 'sourcing registers 2 gem aliases (gemb gemp)' {
    local count
    count=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-gem-completion.plugin.zsh' 2>/dev/null
        alias | grep -cE '^(gemb|gemp)='
    ")
    assert "$count" equals '2'
}

@test 'gemb resolves to gem build *.gemspec' {
    local body
    body=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-gem-completion.plugin.zsh' 2>/dev/null
        alias gemb
    ")
    assert "$body" contains 'gem build'
    assert "$body" contains '.gemspec'
}

@test 'gemp resolves to gem push *.gem' {
    local body
    body=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-gem-completion.plugin.zsh' 2>/dev/null
        alias gemp
    ")
    assert "$body" contains 'gem push'
    assert "$body" contains '.gem'
}

@test 'plugin sourcing is idempotent' {
    local first second
    first=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-gem-completion.plugin.zsh' 2>/dev/null
        alias | grep -cE '^gem'
    ")
    second=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-gem-completion.plugin.zsh' 2>/dev/null
        source '$pluginDir/zsh-gem-completion.plugin.zsh' 2>/dev/null
        alias | grep -cE '^gem'
    ")
    assert "$first" equals "$second"
}
