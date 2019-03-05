Problems solved:
* Forgotten dependencies: build in isolated environment
* Reactive builds (auto-rebuild): mek watch
* Access to the build environment: eval $(mek)
* What changed since last good build(s) without doing git commit all the time: mek source --good (also: cd toto.err.source/)
* Track downloads of third-party components: build in isolated environment without network access
* Archive of source and all dependencies, including downloaded stuff

Usage:
```
mek build toto         # builds toto or toto.err in case of an error.
                       # Cached errors are displayed early, but the build is retried in case it was a cosmic ray.

mek clean              # only necessary if a hardware or system failure (e.g. out of memory) made a build appear as SUCCESSFUL when it was not
                       # (e.g. a poorly-written test that expected an error, caught an OOM but the real execution would not have produced an error)

mek watch              # rebuilds everything incrementally as soon as sources are modified (threads 1 and 3 or 2 and 3, see below).
mek daemon             # same but with '&' after initialization
mek watch toto         # rebuilds toto incrementally as soon as one of its transitive dependencies is modified

ls                     # show progress next to (future) targets and a symlink to the backup of their source
ls _build.err          # stderr of the last build (if non-empty)
ls _build/err          # stderr of the last build
ls _build/source/      # source of the last build
ls _build/good.source/ # source of the last successful build
ls _build/err.source/  # source of the last failed build
ls toto.err            # stderr when building toto (if non-empty)
ls toto.source         # source of the last build of toto
ls toto.good.source    # source of the last successful build of toto
ls toto.err.source     # source of the last failed build of toto

mek source             # dumps the source of the last build
mek source --good      # dumps the source of the last successful build
mek source --err       # dumps the source of the last failed build
mek source toto        # dumps the source of the last successful build of toto
mek source toto.err    # dumps the source of the last failed build of toto

eval $(mek)            # builds and adds the output bin directory to $PATH etc.
eval "$(mek)"          # same
$(mek)                 # same
. mekfile.sh           # same
mek; copy-paste output # same
$(mek daemon)          # same but detaches right away and builds incrementally in the background

eval $(mek build toto) # adds an output bin directory containing only toto (can be a collection of outputs) to $PATH etc.
mek shell toto         # subshell in the directory and with the env of the recipe that builds toto
mek shell toto.err     # same as above
eval $(mek shell toto) # cd to build directory for toto and add to $PATH etc.

mek archive toto       # toto.tar now contains the source of toto and of all its dependencies with a build.sh
```

Example session:
```
$ $(mek daemon)
$ ls
(toto 60%)  toto.source  toto.c  toto.h
$ ls
toto  toto.source  toto.c  toto.h
$ echo "bad stuff" >> toto.h
$ ls
toto (34%)  toto.c  toto.h
$ ls
toto  toto.source  toto.err  toto.err.source  toto.c  toto.h
$ meld $(mek source --good) $(mek source)
$ echo "fix bug" >> toto.h
$ ls
toto  toto.source  toto.c  toto.h
```

In a `mekfile`:
```
toto: toto.h
# automatic dependency on the gcc executable and on toto.c
# "," is the unquote from scheme, it escapes from the implicitly-quoted shell command.
# Maybe gcc (a variable pointing to a third-party tool) should be distinguished from toto.c (a local file)
> ,gcc ,toto.c -o ,output
```

* Uses hashes, not timestamps
* Builds are done in isolated environments (cd, proot, Nix, chroot, container, VM, whatever is available), which only contain the dependencies.
* Transitions are atomic (mv of a symlink), so that the bin folder in the $PATH contains executables from the same version of the source, not toto from one version and tata from another.
* Two builds can run in parallel without interfering with each other, yet if work can be shared it will be.

Note about build threads:
* Invariant when threads 2 and 3 are enabled: if the user constantly modifies a file, e.g. `while sleep 1; do date > somesource; done` which produces an infinite stream of changes, and one of the versions causes the compiler to deadlock / go in an infinite loop, `mek` will still eventually produce an infinite stream of output binaries, where the latest produced binary is not based on a "very old" change (i.e. it is not a queue of jobs that grows indefinitely). It tries to build the latest changes, but it is resistant to the compiler hanging forever on some inputs, and it is resistant to a rapid stream of changes that could cause a naive algorithm to always restart without ever finishing any build.
* Thread 1 builds, and then checks for new changes. (If the build gets stuck in an infinite loop or deadlocks, the build never finishes and new changes are never taken into account.)
* Thread 2 builds, but aborts and restarts as soon as there's any change. Upon completion it kills threads 1 and 3 because it got a successful build of a more recent version. (If you're constantly modifying and the build takes a while, it never gets a chance to finish.)
* Thread 3 works like thread 1 but aborts if there are new changes and the build took longer than a timeout, e.g. twice the time of the last successful build by any thread and increasing geometrically


Random requirements:
* meta-rules: a rule which returns rules. Can be memoized easily, and be part of the normal reactive flow.
* Easy changes of config: dev / build, -O3, -Odebug etc.