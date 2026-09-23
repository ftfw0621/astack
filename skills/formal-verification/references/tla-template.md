# TLA+ template

The shape that keeps a spec tied to the code. Copy it and replace every placeholder.

```tla
---------------------------- MODULE <Name> ----------------------------
(***************************************************************************)
(* Model of <the protocol> (<ticket or ADR>).                              *)
(*                                                                         *)
(* Code mapping (<repo path>):                                             *)
(*   <Action>        <file>:<function>  (<one line on what it does>)       *)
(*   <Action>        <file>:<function>                                     *)
(*   Crash           <how the process dies and what that releases>         *)
(*                                                                         *)
(* Modelling assumptions (platform or design guarantees, not proven here): *)
(*   - <one transaction commits atomically>                                *)
(*   - <a session lock dies with its session>                              *)
(*                                                                         *)
(* Bug switches (each a debated design element; flipping it must make TLC *)
(* produce the concrete failure):                                          *)
(*   <UseLock> = FALSE: <what breaks> (<Invariant>).                       *)
(***************************************************************************)
EXTENDS Naturals, FiniteSets

CONSTANTS <Actors>, <SizeBound>, <RestartBound>, <UseLock>

VARIABLES <state1>, <state2>
vars == <<state1, state2>>

TypeOK == /\ state1 \in <domain>
          /\ state2 \in <domain>

Init == /\ state1 = <initial>
        /\ state2 = <initial>

<Action>(a) == /\ <guard mirroring the code's condition>
               /\ state1' = <update>
               /\ UNCHANGED <<state2>>

Crash(a) == /\ <restart budget>
            /\ <what the crash releases>

Next == \E a \in <Actors> : <Action>(a) \/ Crash(a) \/ ...

Spec == Init /\ [][Next]_vars /\ WF_vars(Next)

<SafetyInvariant> == <the property sentence from the triage record, as a predicate>
<LivenessProperty> == <>[](<the eventual state>)
=============================================================================
```

Configs:

```
\* <Name>.cfg: the real protocol, small scale. Everything must pass.
SPECIFICATION Spec
CONSTANTS  <Actors> = {a1, a2, a3}  <SizeBound> = 2  <RestartBound> = 1  <UseLock> = TRUE
INVARIANTS TypeOK  <SafetyInvariant>
PROPERTIES <LivenessProperty>
CHECK_DEADLOCK FALSE
```

```
\* No<Switch>.cfg: bug demo. Must FAIL <SafetyInvariant> with a trace.
SPECIFICATION Spec
CONSTANTS  <Actors> = {a1, a2, a3}  <SizeBound> = 2  <RestartBound> = 1  <UseLock> = FALSE
INVARIANTS <SafetyInvariant>
CHECK_DEADLOCK FALSE
```

Run and record:

```bash
java -cp tla2tools.jar tlc2.TLC -workers auto -config <Name>.cfg <Name>.tla
java -cp tla2tools.jar tlc2.TLC -workers auto -config Large.cfg <Name>.tla
java -cp tla2tools.jar tlc2.TLC -config No<Switch>.cfg <Name>.tla   # expect an error trace
```

The README next to the spec lists every config, the command, the state count, and the result. A negative config that passes is a modelling bug. Fix it before trusting the positive runs.
