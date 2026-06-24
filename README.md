```
 ███████╗███████╗██╗  ██╗
 ╚══███╔╝██╔════╝██║  ██║
   ███╔╝ ███████╗███████║
  ███╔╝  ╚════██║██╔══██║
 ███████╗███████║██║  ██║
 ╚══════╝╚══════╝╚═╝  ╚═╝
       [ g e m ]
```

[![CI](https://github.com/MenkeTechnologies/zsh-gem-completion/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/zsh-gem-completion/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![zsh](https://img.shields.io/badge/zsh-plugin-cyan.svg)](https://github.com/MenkeTechnologies/zpwr)

### `[RUBY GEM COMPLETION FOR ZSH // REMOTE GEMS VIA gem search]`

> *"`gem install <TAB>` queries the remote index."*

This plugin has all functionality of OMZ gem completion but it also allows `gem install <tab>` to complete remote gems from output of `gem search`.

### [`strykelang`](https://github.com/MenkeTechnologies/strykelang) · [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`MenkeTechnologiesMeta`](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta) · [`zsh-cargo-completion`](https://github.com/MenkeTechnologies/zsh-cargo-completion) · [`zsh-pip-description-completion`](https://github.com/MenkeTechnologies/zsh-pip-description-completion) · [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) · [`zpwr`](https://github.com/MenkeTechnologies/zpwr)

### [`Read the Docs`](https://menketechnologies.github.io/zsh-gem-completion/) &middot; [`Engineering Report`](https://menketechnologies.github.io/zsh-gem-completion/report.html)

---

## Table of Contents

- [\[0x00\] Install for Zinit](#0x00-install-for-zinit)
- [\[0x01\] Install for Oh My Zsh](#0x01-install-for-oh-my-zsh)
- [\[0x02\] General Install](#0x02-general-install)

---

## [0x00] Install for Zinit
> `~/.zshrc`
```sh
source "$HOME/.zinit/bin/zinit.zsh"
zinit ice lucid nocompile
zinit load MenkeTechnologies/zsh-gem-completion
```

## [0x01] Install for Oh My Zsh

```sh
cd "$HOME/.oh-my-zsh/custom/plugins"  && git clone https://github.com/MenkeTechnologies/zsh-gem-completion.git
```

Add `zsh-gem-completion` to plugins array in ~/.zshrc

## [0x02] General Install

```sh
git clone https://github.com/MenkeTechnologies/zsh-gem-completion.git
```

source zsh-gem-completion.plugin.zsh or add code to zshrc or any startup script
