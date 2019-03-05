#!/bin/sh
# align on "->" and "[" keyboard macro:
# (fset 'indent->\[ [C-home ?\C-s ?. ?d ?i ?g ?r ?a ?p ?h ?\C-m home ?\C-  ?\C-s ?. ?\} ?\C-m ?\M-x ?a ?l ?i ?g ?n ?- ?r ?e ?g ?e ?x ?p ?\C-m ?- ?> ?\C-m C-home ?\C-m ?\C-? ?\C-s ?. ?d ?i ?g ?r ?a ?p ?h ?\C-m home ?\C-  ?\C-s ?. ?\} ?\C-m ?\M-x ?a ?l ?i ?g ?n ?- ?r ?e ?g ?e ?x ?p ?\C-m ?\[ ?\[ ?\] ?\C-m ?\C-m ?\C-?])

(sed -e '/^\./!s/^\( *\)\([^ "][^ ]*\)/\1"\2"/' \
|sed -e '/^\./!s/^\( *\([^-]\|-[^>]\)\+ *-> *\)\([^ "][^ ]*\)/\1"\3"/' \
|sed -e '/^\./!s/3rdpartybin/shape=box/' \
|sed -e '/^\./!s/3rdpartyplatform/shape=box/' \
|sed -e '/^\./!s/bdep/style=dashed/' \
|sed -e '/^\./!s/rdep/style=solid/' \
|sed -e '/^\./!s/\([[].*\)mostly-solved/\1fillcolor=yellow,style=filled/' \
|sed -e '/^\./!s/\([[].*\)unsolved+problem/\1fillcolor=red,style=filled/' \
|sed -e '/^\./!s/\([[].*\)many-to-do-ok/\1fillcolor=azure,style=filled/' \
|sed -e '/^\./!s/\([[].*\)many-to-do/\1fillcolor=deepskyblue,style=filled/' \
|sed -e '/^\./!s/\([[].*\)unsolved/\1fillcolor=orange,style=filled/' \
|sed -e '/^\./!s/\([[].*\)solved/\1fillcolor=darkolivegreen1,style=filled/' \
|sed -e '/^\./!s/\([[].*\)implemented/\1fillcolor=green,style=filled/' \
|sed -e '/^\./!s/\([[].*\)currentwip/\1color=green,penwidth=5/' \
|sed -e '/^\./!s/\([[].*\)wip/\1color=green,penwidth=5,style="filled,dashed"/' \
|sed -e 's/^\./ /') <<'EOF'
.digraph g {
. compound=true
. subgraph cluster_legend {
.   label=legend
.   subgraph cluster_legend_deps {
.     label="dependencies"
      "third-party tool"                                   [3rdpartybin]
      component              -> build-dep                  [bdep]
      component              -> run-time-dep               [rdep]
.   }
.   subgraph cluster_legend_solved {
.     label="solved (theoretically)"
.//     subgraph cluster_legend_solved_ok {
.//       style=invis label="";
        implemented                                        [implemented]
        solved                                             [solved]
        many-to-do-ok                                      [many-to-do-ok,label="many to implement\nsimpler workaround"]
.//     }
.//     subgraph cluster_legend_solved_problem {
.//       style=invis label="";
        "mostly solved"                                    [mostly-solved]
        unsolved                                           [unsolved]
        many-to-do                                         [many-to-do, label="many to implement\n500-page standards\npoorly explained\npoorly indexed"]
        "open problem?"                                    [unsolved+problem]
.//     }
.   }
.   subgraph cluster_legend_implem {
.     label="implementation"
      wip                                                  [wip,fillcolor=none]
      "current wip"                                        [currentwip]
.   }
. }

. subgraph cluster_host_platform {
.   label="host platform"
    host-platform                                          [3rdpartyplatform,label="host = one of …"]
    sh                                                     [3rdpartyplatform]
    x86-bootsector                                         [3rdpartyplatform]
    raspberry-pi                                           [3rdpartyplatform]
    windows-.exe                                           [3rdpartyplatform]
    html+js                                                [3rdpartyplatform]
    host-platform-more                                     [3rdpartyplatform,label="…"]
. }
  host-platform              -> sh                         [rdep]
  host-platform              -> x86-bootsector             [rdep]
  host-platform              -> raspberry-pi               [rdep]
  host-platform              -> windows-.exe               [rdep]
  host-platform              -> html+js                    [rdep]
  host-platform              -> host-platform-more         [rdep]

. subgraph cluster_build_os {
.   label="bootstrap build of the OS"
    nano-scheme                                            [solved,currentwip]
    micro-scheme                                           [solved]
    reproducible-environment                               [solved]
    chameleon                                              [solved,wip]
    build-system                                           [mostly-solved]
    bootstrappable                                         [solved]
    gcc                                                    [3rdpartybin]
    sgdisk                                                 [3rdpartybin]
    zip                                                    [3rdpartybin]
    other-chameleon-tools                                  [3rdpartybin,label="other tools"]

    micro-scheme             -> nano-scheme                [rdep]
    build-system             -> micro-scheme               [rdep]
    Guix                     -> "Guix bootstrap"           [bdep]
    Nix                      -> Guix                       [bdep]
    build-system             -> bootstrappable             [rdep]
    build-system             -> reproducible-environment   [rdep]
    chameleon                -> build-system               [rdep]
    chameleon                -> gcc                        [rdep]
    chameleon                -> sgdisk                     [rdep]
    chameleon                -> zip                        [rdep]
    chameleon                -> other-chameleon-tools      [rdep]
    proot                                                  [3rdpartybin]
    run-in-emulator                                        [solved,wip]
.   subgraph cluster_tests {
.     label="tests"
      tests/portability                                    [label=portability]
      tests/gui                                            [label=gui]
      tests/bootstrappable-builds                          [label="build is\nbootstrappable"]
      subimage-search                                      [implemented]
      tests/reproducible-builds                            [label="build is\nreproducible"]
.   }
    qemu                                                   [3rdpartybin]
.   subgraph cluster_repro_env {
.     label="reproducible build environment (software, hardware)"
      reproducible-environment
      Nix          
      proot        
      "POSIX system"                                       [3rdpartyplatform]
.   }
. }
. subgraph cluster_programming_language {
.   label="programming language"
    programming-language
    typesystem                                             [mostly-solved]
    syntax                                                 [solved]
    semantics                                              [mostly-solved]
    vm                                                     [unsolved]
    IDE                                                    [solved]
    refactoring                                            [mostly-solved]
    hyper-literate                                         [solved]
    "package management\n(deps & versions)"                [unsolved+problem]
. }
. subgraph cluster_portble_platform {
.   label="portable platform"
    "portable execution stubs"
    basic-drivers                                          [solved]
    "more drivers\n(udi,hypervised linux)"                 [many-to-do-ok]
. }
  vm                         -> "portable execution stubs" [rdep]
  "portable execution stubs" -> chameleon                  [bdep]
  "portable execution stubs"                               [solved]
  run-in-emulator
. subgraph cluster_gui {
.   label="gui"
    gui                                                    [mostly-solved]
    constraint-solver                                      [mostly-solved]
    graph-layout                                           [unsolved]
    constraint-solver-contract                             [unsolved+problem]
    relative-arbitrary-precision                           [mostly-solved]
    zoomable                                               [mostly-solved]
. }
. subgraph cluster_document_model {
.   label="document model"
    "general\nprinciples"                                  [solved]
.   subgraph cluster_viewers {
.     label="viewers"
      "rich text lens"                                     [solved]
      "list lens"                                          [solved, label="column-list lens"]
      "set lens"                                           [solved]
      "compound document lens"                             [solved]
.   }
.   subgraph cluster_tools {
.     label="tools"
      sort                                                 [solved]
      filter                                               [solved]
      project                                              [solved]
      other-tools                                          [mostly-solved,label="…"]
.   }
.   subgraph cluster_algorithms {
.     label="algorithms"
      other-algorithms                                     [label="…",many-to-do]
      "abstract datatypes"                                 [solved]
      union-find                                           [solved]
      "sat solver"                                         [solved]
      raytracing                                           [solved]
      sort-algo                                            [label="sort",solved]
.   }
.   subgraph cluster_documents {
.     label="data / document types"
      transformation-of                                    [solved]
      styled-layout-of                                     [solved]
      printable-layout                                     [unsolved]
      compound-document                                    [solved]
.     subgraph cluster_simple_data {
.       label="simple data"
        "vectorial image"                                  [unsolved]
        "bitmap image"                                     [solved]
        set                                                [solved]
        list                                               [solved,label="list / database"]
        "rich text"                                        [solved]
.     }
.   }
.   subgraph cluster_data_sources {
.     label="data sources"
.     subgraph cluster_importers {
.       label="importers"
        "word"                                             [many-to-do]
        "excel"                                            [many-to-do]
        "PDF"                                              [many-to-do]
        "RTF"                                              [many-to-do]
        "PSD"                                              [many-to-do]
        "SVG"                                              [many-to-do]
.     }
.     subgraph cluster_network {
.       label="network and protocols"
        "websites\n(webkit in sandbox)"                    [many-to-do-ok]
        more-network-protocols                             [many-to-do, label="…"]
        "NTP"                                              [solved]
        "REST APIs"                                        [many-to-do]
.     }
.   }
. }
  "REST APIs"                -> compound-document          [ltail=cluster_data_sources,lhead=cluster_documents]
  compound-document          -> styled-layout-of
  compound-document          -> transformation-of
  compound-document          -> list                       [lhead=cluster_simple_data]
  styled-layout-of           -> printable-layout
  "list lens"                -> compound-document          [ltail=cluster_viewers,lhead=cluster_documents]
. /*
  "list lens"                -> list
  "set lens"                 -> set
  "compound document lens"   -> "compound document"
  "rich text lens"           -> "rich text"
. */
  "set lens"                -> gui [rdep,ltail=cluster_viewers]
. /*
  "set lens"                 -> gui
  "compound document lens"   -> gui
  "rich text lens"           -> gui
. */
  "compound document lens"   -> constraint-solver
  "compound document lens"   -> graph-layout
  sort                       -> sort-algo                  [rdep,ltail=cluster_tools,lhead=cluster_algorithms]
  other-algorithms           -> "abstract datatypes"       [rdep]
  union-find                 -> "abstract datatypes"       [rdep]
  "sat solver"               -> "abstract datatypes"       [rdep]
  raytracing                 -> "abstract datatypes"       [rdep]
  sort-algo                  -> "abstract datatypes"       [rdep]
  sort                       -> compound-document          [rdep,ltail=cluster_tools,lhead=cluster_documents]
  list                       -> typesystem                 [bdep,ltail=cluster_documents]
. /*
  sort                       -> list
  filter                     -> list
  project                    -> list
. */
  reproducible-environment   -> Nix
  reproducible-environment   -> proot
  reproducible-environment   -> run-in-emulator
  reproducible-environment   -> "POSIX system"
  tests/portability          -> subimage-search            [rdep]
  tests/gui                  -> subimage-search            [rdep]
  tests/portability          -> run-in-emulator            [rdep]

  nano-scheme                -> sh                         [rdep]
  gui                        -> basic-drivers              [rdep]
  Guix                                                     [3rdpartybin]
  "Guix bootstrap"                                         [3rdpartybin]
  Nix                                                      [3rdpartybin]
  basic-drivers              -> host-platform              [rdep]
  gui                        -> programming-language       [bdep]
  programming-language       -> typesystem                 [rdep]
  programming-language       -> vm                         [rdep]
  run-in-emulator            -> qemu                       [rdep]
  subimage-search
  tests/reproducible-builds
  "portable execution stubs" -> "host-platform"            [rdep]


  SVG                        -> "REST APIs"                [style=invis]
  many-to-do-ok              -> "current wip"              [style=invis]
  printable-layout           -> "zoomable"                 [style=invis]
  _sh                                                      [style=invis]
  _sh                        -> "sh"                       [style=invis]
  "current wip"              -> "general\nprinciples"      [style=invis]
  "Guix bootstrap"           -> _sh                        [style=invis]
  styled-layout-of           -> set                        [style=invis]
  "general\nprinciples"      -> "list lens"                [style=invis]
.}

EOF


#dynalist → c'est une mind map (moche) avec des checkbox, dates et hashtags?
# mode lecture 1 focus, édition 1 focus, édition+référence: 2 focus, édition+référence+outils: 3 focus, édition+référence+calculs+style+outils: 5 focus


# DK encyclo vs. Android encyclopedias
# DK book on multimedia
# keyboard
# hw difficulties:
# * PCB layout: lots of interferences (see rowhammer…)
# * GPU is one of the most opaque components. In the Raspberry Pi it means that the boot process is partially opaque.
# * Stateless : a lot of components have flashable firmware nowadays
# * Opaque / undocumented HW
# * casing (high precision otherwise buttons get stuck or jiggle)
# * If you want to make your own hardware, probably best is to hire someone who did it for a small-scale project (e.g. EvilDragon who did the Pandora and Pyra)
