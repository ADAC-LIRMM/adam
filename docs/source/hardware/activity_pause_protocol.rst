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

.. note::

   It was later perceived that ADAM's Activity Pause Protocol closely resembles
   AXI's low-power interface.
   While a complete overhaul to match AXI's version is not planned, the
   protocol may undergo a revision to improve interoperability should any
   critical issues arise.

Signals
=======

- ``clk`` (clock): Typically triggered on the positive edge.

- ``rst`` (reset): A synchronous signal that initiates a reset operation. It
  should not be assumed that it persists for more than one clock cycle.

- ``req`` (request): Used by the master to indicate a wish to pause
  the slave's operations.

- ``ack`` (acknowledge): Used to acknowledge the pause request.

States
======

The protocol defines three states for the slave:

- **ACTIVE**:
  Normal operational state; the slave's internal logic is active and can change
  with every clock cycle.
  The slave is in this state when ``req`` or ``ack`` is deasserted (0).
  The ``rst`` signal should always be deasserted (0) in this state.

- **PAUSE**:
  Safe for clock gating (internal logic is held in a stable, paused condition).
  The slave is in this state when both ``req`` and ``ack`` are asserted (1).
  The ``rst`` signal should always be deasserted (0) in this state.

- **STOP**:
  Safe for both clock gating and power gating (the slave's state can be lost).
  The slave is in this state when ``rst``, ``req`` and ``ack`` are all
  asserted (1).

Protocol Operation
==================

The following figure illustrates how the slave transitions among the three
states (**STOP**, **ACTIVE**, and **PAUSE**).
They need not occur in a strict sequential order;
each transition can happen whenever its conditions are met.

.. figure:: ./images/activity_pause_protocol.drawio.svg
   :align: center

   Typical Timing Diagram of Activity Pause Protocol

The following transitions describe how the slave moves between the three states.
They need not occur in a strict sequential order, each transition can happen
whenever its conditions are met.

- **From STOP to ACTIVE**:
  Deassert both ``rst`` and ``req``.
  The slave responds by deasserting ``ack`` to confirm the transition.

- **From ACTIVE to PAUSE**:
  The master asserts ``req`` while ``rst = 0``.
  The slave then asserts ``ack`` to indicate it is safely paused.

- **From PAUSE to STOP**:
  While paused (``rst = 0``, ``req = 1``, ``ack = 1``), assert ``rst = 1``.
  The slave moves to the **STOP** state, allowing power gating.

- **From PAUSE to ACTIVE**:
  Deassert ``req`` while ``rst = 0``.
  The slave deasserts ``ack`` to confirm a return to active operation.

A typical design should keep the ``req`` and ``ack`` signals enabled during a
reset.
In other words, the initial state should be the PAUSE or STOP state.
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
