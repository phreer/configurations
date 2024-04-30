# Init script convention

`$PREFIX_OS-init.$SUFFIX_SHELL` is the (platform and shell specific) entry
point to our init script to which `$HOME/$PREFIX_OS-init.$SUFFIX_SHELL` will be
linked and `$SUFFIX_SHELL` could be `sh` or `zsh` for bash and zsh,
respectively.

OS-agnostic configuration goes into file `init.$SUFFIX_SHELL`, accessible
by link `$HOME/init.$SUFFIX_SHELL`.

As for shell-agnostic configuration, we put it in file
`$PREFIX_OS-init.rc` and link it to `$HOME/$PREFIX_OS-init.rc`.

For really common things that are both OS-agnostic and shell-agnostic, we have
`init.rc`.

```
$PREFIX_OS-init.$SUFFIX_SHELL
  => init.rc
  => $init-common.$SUFFIX_SHELL
  => $PREFIX_OS-init-common.rc
```
