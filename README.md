vim-mave
====================================================================================================
fat wrapper plugin for `mvn'.

INSTALL
====================================================================================================
write below to your `$MYVIMRC`.

```vim:neobundle-config
NeoBundle 'kamichidu/vim-mave', {
\   'build': {
\       'windows': 'cpanm --installdeps .',
\       'unix':    'cpanm --installdeps .',
\   },
\}
```
