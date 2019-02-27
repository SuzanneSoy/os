Simple build system.

* Purely functional
* Runs commands in isolated environments (virtual machine or `chroot` or `proot` with `env -i`)
* Inputs are distinguished at the syntactic level, and dependencies are automatically computed
* Does not rely on filesystem timestamps
* Results are memoized (if an output happens to be the same after regeneration, it will not be seen as an updated dependency)
