=======================
Activity Pause Protocol
=======================

Introduction
============

The Activity Pause Protocol aims to provide an effective strategy for safe
clock gating, power gating, and non-volatile exploration.
Drawing inspiration from the AXI stream ``READY`` and ``VALID`` signals, this
protocol offers a combination of control simplicity with minimal overhead.

With the objective of devising an effective strategy for clock gating, power
gating and non-volatile exploration, we converged on a protocol that was both
simple and powerful.
Taking inspiration from the AXI stream ``READY`` and ``VALID`` signals, this
protocol merges ease of control with minimal overhead.

Signals
=======

Primary Signals:

- ``pause_req`` (Pause Request): Used by the master to indicate a wish to pause
  the slave's operations.

- ``pause_ack`` (Pause Acknowledge): Used to acknowledge the pause request.

Additional Standardized Signals:

- ``clk`` (clock): Typically triggered on the positive edge.

- ``rst`` (reset): A synchronous signal that initiates a reset operation. It
  should not be assumed that it persists for more than one clock cycle.

- ``test``: Simplifies testing by bypassing or enabling all clock gates in
  hierarchical operation.

Protocol Flow
=============

1. **Pause Request by Master**: The master asserts ``pause_req`` and waits for
   the assertion of ``pause_ack``.
   Notably, ``pause_ack`` could potentially be asserted already.

2. **Slave Paused State**: When ``pause_req`` and ``pause_ack`` are both
   asserted the slave's paused state.
   In this state, the slave remains stable without any changes.

3. **Resumption of Operations**: To restart operations, the master deasserts
   ``pause_req`` and waits for the slave to reciprocate by deasserting
   ``pause_ack``.

The core objective behind introducing this protocol is to allow safe
clock-gating and power-gating during a paused state or stopped state for a
given module. 

The protocol is also designed to operate hierarchically, thereby possibly
incorporating clock gates. Therefore, the ``test`` signal plays an important
role.
Thinking in lines of design for testability, this signal bypasses (or enables)
all clock gates, simplifying the testing process.

Moreover, a typical design should keep the ``pause_ack`` signal enabled during
a reset.
This ensures that even when a module is reset, it still adheres to this
protocol.
On the other hand, if a module wishes to indicate non-compliance or non-support
for the protocol, it can permanently tie ``pause_ack`` low.

Drawing a parallel with the AXI stream signals, just as the ``VALID`` signal
cannot be retracted post-assertion if the transaction remains incomplete,
``pause_req``, following a transition, must await the corresponding transition
by ``pause_ack`` before undergoing another transition.
Conversely, ``pause_ack`` doesn't carry this restriction, but only in a
specific scenario.
For instance, if ``pause_ack`` is low and intends to transition high, it's
permissible. However, reversing this transition while paused isn't allowed, as
it would inadvertently lead to a prohibited state change.