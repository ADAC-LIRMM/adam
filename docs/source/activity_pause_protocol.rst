
.. _activity_pause_protocol:

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

.. note::

   It was later perceived that ADAM's Activity Pause Protocol closely resembles
   AXI's low-power interface.
   While a complete overhaul to match AXI's version is not planned, the
   protocol may undergo a revision to improve interoperability should any
   critical issues arise.

Signals
=======

Primary Signals:

- ``req`` (request): Used by the master to indicate a wish to pause
  the slave's operations.

- ``ack`` (acknowledge): Used to acknowledge the pause request.

Additional Standardized Signals:

While not rigidly defined by the protocol, the clock and reset signals are of
course vital for any sequential module but are even more crucial to this
protocol.
Their states are instrumental in defining the low power mode a module will
enter.

- ``clk`` (clock): Typically triggered on the positive edge.

- ``rst`` (reset): A synchronous signal that initiates a reset operation. It
  should not be assumed that it persists for more than one clock cycle.

Protocol Flow
=============

1. **Request**: The master asserts ``req`` and waits for the assertion of
   ``ack`` by the slave.
   Notably, ``ack`` could potentially be asserted already.

2. **Acknowledgement**: While ``req`` and ``ack`` are both
   asserted the slave is said to be in a paused state.
   In this state, the slave remains stable without any internal state changes.

3. **Resume**: To resume operations, the master deasserts ``req`` and waits for
   the slave to reciprocate by deasserting ``ack``.

The core objective behind introducing this protocol is to allow safe
clock-gating and power-gating during a paused state or stopped state for a
given module. 

A typical design should keep the ``req`` and ``ack`` signals enabled during a
reset.
In others words, the initial state should be the paused state. 
This ensures that even when a module is reset, it still adheres to this
protocol.
On the other hand, if a module wishes to indicate non-compliance or non-support
for the protocol, it can permanently tie ``ack`` low.

Drawing a parallel with the AXI stream signals, just as the ``VALID`` signal
cannot be retracted post-assertion while the transaction remains incomplete,
``req``, following a transition, must await the corresponding transition by
``ack`` before undergoing another transition.
Conversely, ``ack`` doesn't carry this restriction, but only in a specific
scenario.
For instance, if ``ack`` is low and intends to transition high, it's
permissible. 
However, reversing this transition while paused isn't allowed, as it would
inadvertently lead to a prohibited state change.