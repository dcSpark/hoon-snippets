# Writing Robust Hoon - A Guide To Urbit Unit Testing

[Urbit](https://urbit.org) supports [peer-to-peer software distribution](https://urbit.org/docs/userspace/dist/dist) using public desks (analogous to Git branches). This opens up a wide array of possibilities, however as a developer how can you have confidence in the performance and behavior of Gall agents you write?

Unit testing is one of the available approaches which allows you to verify expected behavior as rigorously as you choose.

Since Urbit runs as a virtualized Nock machine, you don't have to worry about memory management and other runtime binary concerns. Nor do you have to worry too much about external penetration testing (as long as you rely on Urbit system services to authenticate callers as necessary). However, you still need to make sure that library code and applications do what they are advertised to do.

As such in this post we will be diving into how to go about unit testing your Gall agents and thereby ensuring your end users will have a smooth experience.

## The Structure of a Unit Test

A unit test measures program results against a known standard of behavior. Ideally a unit test examines the single orthogonal aspect of a function or feature. Discrete test composition makes it easier to narrow down misbehavior.

Hoon provides two built-in unit testing tools:

1. `-test` is a thread which locates and runs unit tests at a specified path, by convention in `/tests` at the path of the corresponding file.
2. `%test` is a Gall agent that builds all of `%generators`, `%agents`, or `%marks`, confirming basic operability.

### `-test` Thread

`-test` unit tests are included in a `|%` barcen core and consist of chained [`tang`](https://urbit.org/docs/hoon/reference/stdlib/2q#tang)s (formatted output structures) produced by `++expect-eq` (equality of two values) and `++expect-fail` (failure/crash). By convention, the expected value is listed first and the actual value second.

**`/tests/lib/fib/hoon`**:

```
++  test-fibonacci
  ;:  weld
  %+  expect-eq
    !>  ~[1 1 2 3 5 8]
    !>  (fib 6)
  ==
```

For instance, suppose one wished to test the (real) Hoon gate `++sub`. The following tests would verify that integer subtraction works as expected. Many unit tests may appear trivial because they are spot checks that things work as expected.

**`/tests/lib/sub/hoon`**:

```
/+  *test
|%
++  test-zero
  ;:  weld
  %+  expect-eq
    !>  0
    !>  (sub 0 0)
  %+  expect-eq
    !>  1
    !>  (sub 1 0)
  %+  expect-eq
    !>  0
    !>  (sub 20 20)
  %-  expect-fail
    |.  (sub 0 1)
  ==
++  test-one
  ;:  weld
  %+  expect-eq
    !>  0
    !>  (sub 1 1)
  %+  expect-eq
    !>  1
    !>  (sub 2 1)
  %+  expect-eq
    !>  19
    !>  (sub 20 1)
  %-  expect-fail
    |.  (sub 1 2)
  ==
--
```

Unit tests are frequently used with a testing framework which provides a scaffolding for running many tests at a time. In this case, we use the `-test` thread. Save the foregoing code on a new `%sandbox` desk at `/tests/lib/sub/hoon`

```
dojo> |merge our %base %sandbox
:: copy the code in on the Unix side
dojo> |commit %sandbox
```

and run the tests with

```
dojo> -test /=sandbox=/tests/lib/sub/hoon ~
```

You should see a notification for each test in the core at that path:

```
built   /tests/lib/sub/hoon
OK      /lib/sub/test-zero
OK      /lib/sub/test-one
```

### `%test` Agent

The `%test` agent is more macroscopic than `-test`, building all of `%generators`, `%agents`, or `%marks`. Using `%test` builds all of the candidate elements on the `%base` desk. (As of this January 2022 writing, cross-desk execution is in development by Tlon.) As desk affordances are built out, an equivalent operation should be introduced to check other desks.

```
dojo> |start %test
dojo> :test %agents
>=
built   /app/acme
built   /app/aqua
built   /app/azimuth
built   /app/azimuth-rpc
built   /app/azimuth-tracker
built   /app/claz
built   /app/dbug
built   /app/dns-collector
built   /app/dojo
built   /app/eth-sender
built   /app/eth-watcher
built   /app/gaze
built   /app/herm
built   /app/hood
built   /app/language-server
built   /app/lens
built   /app/ping
built   /app/roller
built   /app/roller-rpc
built   /app/shoe
built   /app/spider
built   /app/test
built   /app/time
%all-agents-built
> :test %agents
>=
```

The `%test` Gall agent forms part of the system-wide integrity check for a distributed desk, but for the most part we will rely on the `-test` thread to validate program behavior.

Between the two methods, note any failed tests. The test and the code should both be examined to determine which is at fault and then corrected. Once a high degree of confidence has been attained in the unit tests, then these may be reliably used to identify failures in a repeatable and auditable way. You should construct a small matrix of common failures, even if trivial, then use your imagination to examine more liminal cases. In addition, any time a failure arises in practice, a unit test should be added to hedge against its occurrence in the future. Rigorous discipline in unit testing will reduce the number of errors in the codebase and occasionally unmask latent errors.

## Basic Debugging on Urbit

What do we mean when we say something has gone wrong? It means that a result happened in contravention of our expectation. Some bugs yield subtle errors: they are transient, or embedded in the seventh decimal place. Others are dramatic, such as crashes or absurd results. We will call an _error_ the actual source of a bug. Essentially any nontrivial program has bugs of varying severity. A _failure_, on the other hand, is an observable, the incorrect behavior of a program. A failure can reveal itself as an actual crash or an incorrect behavior or result.

Tests should find things that are supposed to go right and things that are supposed to go wrong (i.e. expected errors/crashes, perhaps due to bad input).

For all our rigor, Dijkstra reminds us that:

> Program testing can be used to show the presence of bugs, but never to show their absence.

Due to the structure of the Urbit runtime, entire categories of errors are impossible to the pure Hoon virtual machine layer: no null pointer dereferencing, no deadlocks, no underflows. (This doesn't prevent the possibility of memory leaks or array bound overwrites in the runtime or jets, of course, but we set those aside and assume the runtime works as advertised, generally a good assumption so far.)

Hoon encourages a “traditional” style of debugging, relying on debugging `printf`s ([`~&` sigpam](https://urbit.org/docs/hoon/reference/rune/sig#-sigpam) with logging degrees `>` info, `>>` warning, and `>>>` error) and stack trace hints ([`!:` zapcol](https://urbit.org/docs/hoon/reference/rune/zap#-zapcol) to turn on stack trace debugging; [`~|` sigbar](https://urbit.org/docs/hoon/reference/rune/sig#-sigbar) to add an annotation in case of crash). The imperative programming model of breakpoints doesn't map particularly well to functional programming language models and there's not a debugging-oriented step-by-step execution framework right now.

The easiest way to check for errors is simply to aggressively enforce type using the [`^-` kethep](https://urbit.org/docs/hoon/reference/rune/ket#-kethep) and [`^+` ketlus](https://urbit.org/docs/hoon/reference/rune/ket#-ketlus) runes. The static compiler will handle type errors at build time, meaning these by and large do not affect your agent at runtime.

## The Structure of a Gall Agent

Most of the time, Urbit developers will ship Gall agents as their primary product rather than generators or libraries. Recall that a Gall agent has ten arms. In many applications, several are left as default arms which pass-through or do nothing. Prefer to use the `default` library's specification for clarity (rather than rolling your own do-nothing arm).

```
|_  =bowl:gall
+*  this      .
    default   ~(. (default-agent this %|) bowl)
++  on-init   on-init:default
++  on-save   on-save:default
++  on-load   on-load:default
++  on-peek   on-peek:default
++  on-poke   on-poke:default
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
```

Unit tests for several of these arms, such as `++on-init` and `++on-load`, aren't really necessary since any mistake tends to be immediately manifest in development. (For instance, failure to adequately define a state transition in `++on-load` will yield an error.) Others, however, in particular the interaction arms merit rigorous testing. While it has been common to spot-check behaviors interactively, we outline below an approach using automated unit testing which can be used to validate the behavior of each arm.

The `+dbug` generator which can wrap the Gall agent permits a direct view of the agent's internal state. This is crucial for your interactive testing, but insufficient for an automatic testing framework. We emphasize that any internal state variable should have a corresponding peek action.

## An Approach to Testing Gall Agents

### `%hark-store`

The above approach is adequate for library code, but most end-user applications on Urbit are Gall agents.

Conventionally, Urbit instruments unit tests via the `-test` thread, which scans a path for arms beginning with `'test-'` and runs each of them. For instance, to run all the built-in library tests on the `%base` desk, you can use:

```
dojo> =dir %landscape
dojo> -test %/tests/lib ~
```

which will build the tests, run each test, and report:

```
dojo> -test %/tests/lib ~
built   /tests/lib/der/hoon
...
>   test-veri-wrong-key: took 13805µs
OK      /lib/vere/dawn/test-veri-wrong-key
>   test-veri-pawn-key-mismatch: took 19752µs
OK      /lib/vere/dawn/test-veri-pawn-key-mismatch
>   test-veri-pawn-invalid-life: took 16129µs
OK      /lib/vere/dawn/test-veri-pawn-invalid-life
>   test-veri-pawn-good: took 16359µs
OK      /lib/vere/dawn/test-veri-pawn-good
>   test-veri-pawn-already-booted: took 15366µs
OK      /lib/vere/dawn/test-veri-pawn-already-booted
...
```

For `/app` agents, the situation is a bit more complicated. For instance, the agent must be running before tests can be made against the agent. Accommodation must be made for the fact that agents run on different desks.

The only example of `/app` testing in the current Urbit codebase is `%garden`'s `%hark-store`. This constructs a number of specific data structures, inserts them into a `=^`-pinned version of the `%hark-store` agent, and compares for expected results. For instance, here is the logic testing the “half-open” data structure in `++test-half-open-double`, which manages the number of active notifications.

```
++  test-half-open
  =|  run=@ud
  =^  mov1  agent
     (~(on-poke agent (bowl run)) %hark-action !>((add-note run)))
  =^  mova  agent
     (~(on-poke agent (bowl run)) %noun !>(%sane))
  =.  run  +(run)
  =^  mov2  agent
     (~(on-poke agent (bowl run)) %hark-action !>(read-count))
  =^  mov3  agent
     (~(on-poke agent (bowl run)) %noun !>(%sane))
  =/  expected-archive=notification:hark
    [(add *time (mul ~s1 0)) bin ~[(body 0)]]
  =+  !<(=state on-save:agent)
  =/  actual-archive=notification:hark
    (~(got re archive.state) (add *time ~s1) bin)
  (expect-eq !>(expected-archive) !>(actual-archive))
```

This logic does the following:

1. Adds a note and checks state (`%sane`).
2. Sets the read count and checks state (`%sane`).
3. Constructs the reference case `expected-archive`.
4. Retrieves the actual case from `%hark-store`'s state.
5. Asserts equality of the vases.

Another test, `++test-half-open-capped`, adopts a slightly different approach. Basically, this test looks at whether notifications are set and passed through properly.

```
++ test-half-open-capped
  =|  run=@ud
  |-
  ?:  =(run 31)
    =+  !<(=state on-save:agent)
    (expect-eq !>(~) !>(half-open.state))
  =^  movs  agent
    (~(on-poke agent (bowl run)) %hark-action !>((add-note run)))
  =^  mavs  agent
    (~(on-poke agent (bowl run)) %hark-action !>(read-count))
  $(run +(run))
```

This logic does the following:

1. Sets an “uninitialized” `run` counter, which counts the number of moves the state log has recorded.
2. Constructs the agent state with a note added.
3. Constructs the agent state with a read count for the test path.
4. (at the top of the trap) Checks the exit condition and returns the testing arm result.

Running these tests yields the following:

```
dojo> -test %/tests/app/hark-store ~
built   /tests/app/hark-store/hoon
[   by-place
 { [ p=[desk=%landscape path=/graph/~zod/test]
     q={[lid=[%archive time=~2000.1.1..00.00.01] path=/]}
   ]
 }
 ~
]
[   by-place
 { [ p=[desk=%landscape path=/graph/~zod/test]
     q={[lid=[%archive time=~2000.1.1..00.00.01] path=/]}
   ]
 }
 ~
]
>   test-half-open-double: took 28744µs
OK      /app/hark-store/test-half-open-double
>   test-half-open-capped: took 17636µs
OK      /app/hark-store/test-half-open-capped
[by-place={[p=[desk=%landscape path=/graph/~zod/test] q={[lid=[%unseen ~] path=/]}]} ~]
[by-place={[p=[desk=%landscape path=/graph/~zod/test] q={[lid=[%unseen ~] path=/]}]} ~]
[   by-place
 { [ p=[desk=%landscape path=/graph/~zod/test]
     q={[lid=[%archive time=~2000.1.1..00.00.01] path=/]}
   ]
 }
 ~
]
[   by-place
 { [ p=[desk=%landscape path=/graph/~zod/test]
     q={[lid=[%archive time=~2000.1.1..00.00.01] path=/]}
   ]
 }
 ~
]
>   test-half-open: took 30218µs
```

This constructivist approach to testing allows that the developer to control the created agent state sufficiently to verify all behaviors as needed. For instance, note the references in the foregoing testing arms to `++bowl`. This creates an artificial bowl for the agent state:

```
++ bowl
  |=  run=@ud
  ^-  bowl:gall
  :*  [~zod ~zod %hark-store]
    [~ ~]
    [run `@uvJ`(shax run) (add (mul run ~s1) *time) [~zod %garden ud+run]]
  ==
```

As a result of using `run`, each event takes place one second subsequent to the previous event.

The entire testing framework for `%hark-store` can be seen in the Urbit repo on the `%garden` desk at [`/tests/app/hark-store.hoon`](https://github.com/urbit/urbit/blob/master/pkg/garden/tests/app/hark-store.hoon).

Many code features are automatically checked: in particular, problems with `/sur` and `/mar` files are typically caught up front by Hoon's static type checker. E.g., if a `?+` or `?-` switch statement is missing a possible value, the compiler will raise an exception and refuse to build. This simplifies the state conditions that the developer needs to test in `/tests`.

### `%pomodoro`, A Toy Agent

We include a simple agent to illustrate some tests. `%pomodoro` is a prototype [productivity](https://lifehacker.com/productivity-101-a-primer-to-the-pomodoro-technique-1598992730) agent which mock-emits a signal every 25 seconds (in real Pomodoro terms, minutes) and then every 5 seconds (minutes) in alternating intervals to a list of watchers. (We avoid calling these “subscribers” since that has a special meaning in Urbit; it would be compatible with a slight tweak of this demo but requires a testnet or livenet.)

Urbit prefers a data-reactive operating model. Peeks can reveal the internal state of the program, pokes can alter or return state, and subscriptions manage the timer notifications. Some parts of this system are more straightforward to test than others; for instance, adding or removing a watcher from a list should be straightforward (and testable). Other kinds of events may produce follow-on effects or gifts much later (and asynchronously), and are more difficult to test with an automated `-test` thread.

#### Testing `%pomodoro`

To test the behavior of adding a watcher to the list, we need to build a reference state and compare the modified state. For a simple agent, we can do this manually, as below:

```
++ test-add-client
  =| run=@ud
  =^ move agent (~(on-poke agent (bowl run)) %pomodoro-action !>([%add-client ~zod]))
  =+ !<(=state on-save:agent)
  %+ expect-eq
    !> [%0 watchers={~zod} status=%break]   :: reference state
    !> watchers.state                       :: actual state
  ==
```

More moves can of course be chained into this (like `%hark-store` uses) and adding and removing agents can be tested.

After including this testing file, install `%pomodoro` for the first time on your fakezod by following these steps:

1.  Clone the base repo from `dcspark/tutorial-testing`.

    ```
    $ git clone
    ```

2.  Fork off the `%base` desk as `%pomodoro`.

    ```
    dojo> |merge %pomodoro our %base
    dojo> |commit %pomodoro
    ```

3.  Remove all of the contents of `%pomodoro` and copy in the contents of the repo's `/src` directory.

    ```
    $ rm -rf zod/pomodoro/*
    $ cp -r pomodoro/src/* zod/pomodoro
    ```

4.  Commit and install the new desk contents.

    ```
    dojo> |commit %pomodoro
    dojo> |install our %pomodoro
    ```

    (You will see a warning about not having a docket file, but this desk doesn't have an app with a browser front-end.)

5.  If you were working on the `%base` desk, at this point you would use the `%test` agent to make sure it builds properly. (Pending clarification and support for same-named agents across multiple desks.)

6.  Start and poke the agent to test that it works properly.

    ```
    dojo> |start %pomodoro
    dojo> :pomodoro &pomodoro-action [%start-timer ~]
    dojo> :pomodoro &pomodoro-action [%add-client ~zod]
    ```

    At any point, you can also check the agent's state with the `%dbug` wrapper:

    ```
    > :pomodoro +dbug
    [%0 watchers={~zod} status=%break]
    ```

7.  The test cases have been installed and are ready to go in `/tests`. Trigger them using the `-test` thread.

    ```
    dojo> -test ~[/=pomodoro=/tests/app/pomodoro/hoon] ~
    ```

## Testing Agents Automatically with CI

How do we make sure that our tests are run by the continuous integration system? The testing methods we used above can be automatically triggered from outside of a running ship using the Urbit `herb` utility.

The main Urbit repo builds and runs tests on the `%base` desk automatically. The basic testing method can be invoked:

```
$ nix-build -A urbit-tests
```

The tests are triggered in `nix/lib/test-fake-ship.nix`. This triggers all unit tests on the `%base` desk (default `%`).

```sh
herb ./pier -d '~&  ~  ~&  %test-unit-start  ~'
herb ./pier -d '####-test %/tests ~'
herb ./pier -d '~&  ~  ~&  %test-unit-end  ~'
```

For instance, the agent-based unit tests are triggered using `herb` and the `%test` Gall agent:

```sh
herb ./pier -p hood -d '+hood/start %test'

herb ./pier -d '~&  ~  ~&  %test-agents-start  ~'
herb ./pier -p test -d '%agents'
herb ./pier -d '~&  ~  ~&  %test-agents-end  ~'
```

`herb` is a Python interface which can carry out some very limited operations from outside your ship. In this case, it pokes the `%test` agent, which is instrumented for locating and running particular tests. (`####` is a `herb` hack to prevent Bash from expanding the `-test` as a command-line argument.)

Urbit uses [Nix](https://builtwithnix.org/) to manage its runtime build process. Nix uses a functional deployment model to produce reproducible dependencies throughout the build chain. Nix conceives of tests as artifacts of its process, so you may need to make trivial changes to files if you are attempting to see results having run `nix-build -A urbit-tests` previously.

If you are publishing your own software on an Urbit desk, you'll need to set up CI on your own fork on GitHub. (See the `.github` folder in your Urbit repo for examples.)

## Going Further

Other considerations in validating your program's behavior include checking Eyre endpoints, which can use a conventional unit testing framework and Git hooks, for instance, or a continuous integration service.

We would also like to see future development enable developers to test:

- Anticipated system upgrades (e.g. `%zuse` version decrements on a desk)
- Interactions of different versions of Gall agents

As more developers build Urbit tools, including to interact with [dcSpark's Urbit Visor](https://github.com/dcSpark/urbit-visor) flagship, we can use the existing Urbit testing infrastructure to build reliable agents and applications. Urbit makes it easy to use secure primitives and user state in building Web3 applications, while Urbit Visor makes it easy to bridge Web3 back into Web 2.0.
