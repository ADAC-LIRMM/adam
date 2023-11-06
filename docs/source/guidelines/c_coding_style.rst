.. _codingstyle:

==============
C Coding Style
==============

This document outlines the C coding style guidelines for this project,
taking inspiration from the principles of the `Linux kernel coding style`_.
Adherence to these guidelines, while not mandatory, is highly encouraged for
all project code, with the aim of achieving consistency and enhancing
readability.
Exceptions to these rules may be permitted if they substantially enhance the
readability of a particular code section.
Deviations should be minimal to preserve the codebase's consistency.
Suggestions for refining these guidelines are welcome.

.. _Linux kernel coding style: \
	https://www.kernel.org/doc/html/v4.10/process/coding-style.html

Indentation
===========

Use 4 spaces (not ``\t``) for each level of indentation.

A useful guideline is to limit the number of indentation levels.
Exceeding three levels of indentation often indicates a complexity that might
be simplified.
In these situations, consider refactoring to make the code more manageable and
understandable.

The preferred way to ease multiple indentation levels in a ``switch`` statement
is to align the ``switch`` and its subordinate ``case`` labels in the same
column instead of double-indenting the ``case`` labels.
E.g.:

.. code-block:: c

	switch (character) {
	case 'A':
		...
		break;

	case 'B':
	case 'C':
		...
		break;
	
	default:
		break;
	}

Additionally, for both macros and goto statements, do not add indentation.
These elements should remain unindented to distinguish them clearly from the
rest of the code. 

Lines
=====

The line length limit is 80 columns and this is a strongly preferred limit.
Longer statements should be broken into sensible chunks, unless exceeding 80
columns significantly increases readability.

Many text editors offer a ruler feature, which can be a helpful tool in
ensuring compliance with this line length restriction.

Futhermore, don't place multiple statements on a single line. For example, 
don't ever do the following:

.. code-block:: c

	if (condition) extra(); bad(); example();

For variable declarations, it's preferred to allocate one line per variable,
for example:

.. code-block:: c

	int a;
	int b;

Instead of combining declarations on a single line:

.. code-block:: c

	int a, b;

Braces
======

The preferred approach is to position the opening brace at the end of the
initiating line and place the closing brace at the beginning of its own line.
E.g.:

.. code-block:: c

	if (condition) {
		...
	}

This applies to all non-function statement blocks (``if``, ``switch``, ``for``,
``while``, ``do``).

However, there is one special case, namely functions: they have the opening
brace at the beginning of the next line.
E.g.:

.. code-block:: c

	int function(int x)
	{
		...
	}

Note that the closing brace is empty on a line of its own, **except** in
the cases where it is followed by a continuation of the same statement,
i.e. a ``while`` in a do-statement or an ``else`` in an if-statement, like
this:

.. code-block:: c

	do {
		...
	} while (condition);

	if (first_condition) {
		...
	} else if (second_condition) {
		...
	} else {
		...
	}

An exception is made for single-line statements.
If a conditional statement and its corresponding action fit on one line and do
not exceed the line length limit, braces can be omitted:

.. code-block:: c
	
	if (condition) do_this();

In cases where the line would exceed this limit or multiple actions are
involved, braces should be used:

.. code-block:: c

	if (condition) {
		do_this();
		do_that();
	}

Spaces
======

To use of spaces depends mostly on function-versus-keyword usage. Use a space
after most keywords. The notable exceptions are ``sizeof``, ``typeof``,
``alignof``, and ``__attribute__``, which look somewhat like functions and are
usually used with parentheses, although these parentheses are not required by
the language.

So use a space after ``if``, ``switch``, ``case``, ``for``, ``do``, and 
``while``.

Here's an example to illustrate this:

.. code-block:: c
	
	if (condition) {
		...
	}

	for (int i = 0; i < sizeof(int); i++) {
		...
	}

When declaring pointer data or a function that returns a pointer type, the
preferred use of ``*`` is adjacent to the variable or function name and not
adjacent to the type name.
E.g.:

.. code-block:: c

	char *banner;
	int first_function(char *ptr, char **ret);
	char *second_function(char *str);

Use one space around (on each side of) most binary and ternary operators,
such as any of these::

	=  +  -  <  >  *  /  %  |  &  ^  <=  >=  ==  !=  || && ?  :

but no space after unary operators::

	&  *  +  -  ~  !  sizeof  typeof  alignof  __attribute__  defined

no space before the postfix increment & decrement unary operators::

	++  --

no space after the prefix increment & decrement unary operators::

	++  --

and no space around the ``.`` and ``->`` structure member operators.

Avoid trailing whitespaces at the end of lines.
Use an editor that effectively manages indentation and whitespace.
While most editors add necessary whitespace at the beginning of new lines, be
aware that some may not remove it on blank lines.

.. _Naming:

Naming
======

Adopt snake case for multi-word identifiers, writing them in lowercase with 
underscores, e.g., ``user_count``, ``update_records``.
Camel case is discouraged, e.g., ``UserCount``, ``updateRecords``.

Macros are an exception and should follow an all-uppercase version of camel
case, distinguishing them from variables and functions.
E.g.:

.. code-block:: c

	#define MAX_BUFFER_SIZE 1024

Local variables should have concise names. 
For example, use ``tmp`` for a temporary variable and ``i`` for a loop counter. 
These succinct names sufficiently indicate their function. 
Difficulty in differentiating between local variable names often reflects the
function's deficiency in complexity rather than in naming.

Global variables and functions should have descriptive yet concise names,
with a maximum length of 31 characters.
Employ common abbreviations for longer names; for instance,
``calculate_average_salary`` can be shortened to ``calc_avg_salary``.
Ensure that abbreviations are well-documented and easily understandable,
balancing clarity with brevity.

Although Hungarian notation is generally avoided, an exception exists for type
definitions.
They should include a ``_t`` suffix, e.g., ``item_t``, to clearly indicate that
they are type definitions.

.. Type Definitions
.. ================

Functions
=========

Functions should be concise and dedicated to a singular task.
The optimal length of a function is such that it fits within one or two
standard screen views (80x24 characters).
The principle is that a function should have a single responsibility and
execute it effectively.

The acceptable length of a function is inversely proportional to its complexity
and indentation level. 
For instance, a straightforward, lengthy case-statement handling numerous cases
can justify a longer function.
Conversely, more complex functions should be shorter and might necessitate
splitting into smaller, more focused sub-functions.

Regarding local variables, a function should generally use no more than 5-10.
Exceeding this number might indicate that the function is overly complicated
and needs rethinking or dividing into smaller segments.

In your code, maintain a single blank line between functions for clarity.
Moreover, when writing function prototypes, it's beneficial to include
parameter names along with their types.
While not a requirement in C, this enhances the readability and understanding
of the function's intent.

For example, a well-defined function and its prototype might look like this:

.. code-block:: c

	// Prototype
	int check_system_status(int system_id);

	// Function
	int check_system_status(int system_id)
	{
    	...
	}

Goto Statements
===============

The ``goto`` statement, while sometimes controversial, is a practical tool in
functions with multiple exit points, especially when reptitive cleanup actions
are needed.
However, direct  use of ``return`` is preferable in simple cases without the
need for cleanup.

Labels for ``goto`` statements should be purposeful and descriptive.
For instance, ``out_free_buffer:`` should be used for labels associated with
freeing allocated memory, rather than ambiguous labels like ``err1:`` or
``err2:``.

Advantages of using ``goto`` for centralized function exits:

- It simplifies the tracking and understanding of unconditional jumps.
- Reduces the nesting depth of code.
- Helps in maintaining consistency at exit points.
- Assists compiler optimizations by avoiding redundant code.

For example:

.. code-block:: c

	int process_data(int data)
	{
		int result = 0;
		char *buffer;

		buffer = allocate_memory(SIZE);
		if (!buffer) return -ERROR_NO_MEMORY;

		if (condition) {
			...
			result = 1;
			goto out_free_buffer;
		}
		...
	out_free_buffer:
		free_memory(buffer);
		return result;
	}

Be cautious of situations where variables might be uninitialized or ``NULL``
in certain exit paths. 
Using distinct error labels for different cleanup activities can help minimize
this issue.

Commenting (with Doxygen)
=========================

Effective commenting balances clarification and brevity.
Comments should explain the purpose of the code, not its mechanism.
Self-explanatory code negates the need for detailed commentary on mechanics.
Overly complex functions requiring extensive inline comments indicate a need
for simplification.

For comprehensive and structured documentation, we utilize the Doxygen comment 
format, enabling automatic generation of documentation.
Since comments are intended to describe the functionality rather than the
implementation, the majority of comments should be in the Doxygen format.

Each file should begin with a Doxygen block (multi-line) comment providing
essential context and overview.
E.g.:

.. code-block:: c

	/**
     * @file example.c
     * @brief Implementation of example functions used across the application.
     */

Function comments should use the block (multi-line) format and be located at
the function's prototype, usually found in the header file.
E.g.:

.. code-block:: c
	
	/**
	 * @brief Calculates the average of two numbers.
	 *
	 * This function takes two integers and returns their average.
	 * It is particularly useful in scenarios requiring precise average
	 * calculations.
	 *
	 * @param num1 The first number.
	 * @param num2 The second number.
	 * @return The average of num1 and num2.
	 */
	int average(int num1, int num2);

Take note that each line within the comment block should align its ``*`` with
the ``/**`` opening.

Additionally, document any unexpected or externally dependent behavior in
functions, particularly those related to memory allocation.

Comment variables with non-obvious purposes or complex representations using
the single-line ``///`` format for clarity. This is especially important for
all global variables.
E.g.:

.. code-block:: c

	///  Number of attempts before a connection is considered failed.
	int retry_count;

Use the inline ``/**< */`` format for documenting fields, provided it fits
within the line length limit.
E.g.:

.. code-block:: c

	struct example {
		int field; /**< field description */ 
	};

.. Autoformatting
.. ==============

Macros
======

As stated in the :ref:`Naming` section, all macro names must be entirely in
uppercase.
Regardless of whether the macro resembles a function or not.
E.g.:

.. code-block:: c

	#define CONSTANT 0x4000

When a macro is an expression, it should be enclosed in parentheses to maintain
the correct order of operations. 
The same principle applies to arguments within function-like macros; both the
arguments and the expression itself should be enclosed in parentheses to avoid
precedence issues.

.. code-block:: c

	#define CONSTEXP (CONSTANT | 3)
	#define CALCULATE_SUM(a, b) ((a) + (b))

Generally, inline functions are favored over macros that resemble functions.
Inline functions offer type safety and are typically more maintainable than
their macro counterparts.

Macros that consist of multiple statements should be enclosed within a do-while
block:

.. code-block:: c

	#define MACRO_FUN(a, b, c)      \
    do {                            \
        if ((a) == 5) action(b, c); \
    } while (0)

Don't design macros that significantly alter control flow or depend on obscure
local variables. Here's an example of what to avoid:

.. code-block:: c

	#define FOO(x)                             \
        do {                                   \
            if (blah(x) < local_magic) return; \
        } while (0)

Futhermore, be mindful of namespace collisions, particularly when defining
function-like macros.

Minimize the use of ``#ifdef`` for conditional compilation.
While powerful, it can complicate code readability and maintenance.
In many cases, a simple if statement with a constant condition that the
compiler can optimize away is a preferable alternative.
However, there are scenarios where ``#ifdef`` is the best or only option.

For header files, favor ``#pragma once`` over traditional header guards 
(``#ifdef NAME_H ... #endif``) for simplicity and to avoid potential errors.

.. Debug Messages
.. ==============

.. Allocating Memory
.. =================

Inline Functions
================

The inline keyword in C programming is often misconceived as a magic tool for
performance enhancement.
However, excessive use of inline can lead to larger code sizes, potentially
decreasing system efficiency through increased cache misses.

It is advisable to limit inline usage to functions not exceeding three lines,
as longer functions typically gain less from inlining and can contribute to
larger binary sizes.
Exceptions are made for functions with compile-time constant parameters,
where the compiler can optimize most of the function during compilation.

There's also a debate around the use of inline for static functions used only
once, under the presumption of no space trade-off.
While this might seem technically sound, modern compilers like gcc are adept at
automatically inlining these functions when it's beneficial. 
Manually adding inline to these functions might introduce maintenance
challenges if their usage evolves over time.

Return Values
=============

Functions return values in various formats, commonly indicating success or
failure.
This is typically represented in two ways: through an error-code integer or a
boolean value. The error-code integer approach uses negative values for
different failure types and 0 for success.
In contrast, a boolean success indicator uses 0 for failure and any non-zero
value for success.

It's crucial to avoid confusion or mix-ups between these two return value
representations.
Therefore, a convention for function names and their return values is
adopted for clarity.
Functions that perform actions or commands, e.g, ``add_work()``, should return
an error code.
Conversely, predicate functions, e.g., ``is_device_present()``, should
return a boolean value.

Inline Assembly
===============

In architecture-specific coding, inline assembly is often necessary to interact
with CPU or platform specific features.
While it's important to use inline assembly when required, it should not be
used without cause.
Always prefer interacting with hardware using C whenever feasible.

For common inline assembly operations, consider creating simple helper
functions.
These functions can encapsulate frequently used assembly code, reducing
repetition and improving code clarity.
These helper functions can also leverage C parameters, making them more
versatile and integrated with the rest of your C codebase.

For larger and more complex assembly routines, it's advisable to place them in
independent assembly files, accompanied by C prototypes in header files.
When defining C prototypes for assembly functions, the ``asmlinkage`` attribute
should be used.

Be mindful of the ``volatile`` keyword in your inline assembly statements.
Marking an assembly statement as volatile prevents the GCC compiler from
optimizing it away, assuming it detects no side effects.
However, overuse of volatile can hinder other optimizations, so it should be
used judiciously.

When writing inline assembly with multiple instructions, each instruction
should be on a separate line.
E.g.:

.. code-block:: c

	asm ("addi %0, %1, 10\n\t"
    	"sub %0, %0, %2"
     	: "=r" (output)
     	: "r" (reg1), "r" (reg2)
     	: /* clobbers */);

