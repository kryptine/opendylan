*****************
The format Module
*****************

.. current-library:: io
.. current-module:: format

The Format module is exported
from the IO library. This module extends the functionality of the format
strings described in :drm:`Dylan's condition system <Condition_Messages>`
and provides two new functions for processing the extended format strings.
The Format module is a small module, but it uses the printing modules and
some of the Streams module. :doc:`print` and :doc:`streams` give full
details of the Print and Streams libraries.

The ``format`` module exports all the identifiers described in this document.

Control strings
===============

The Format module's format strings, or control strings, offer the same
directives as :drm:`Dylan's format strings <Condition_Messages>` offer,
but Format provides a few more directives, and permits a single argument
to all format directives.

The argument is an integer that must appear contiguously between the
dispatch character, ``%``, and the format directive. The argument
indicates a printing field in which to justify the output of the
directive. A positive integer indicates that the output should be flush
right within the field, and a negative integer indicates the output
should be flush left within the field. If the output length is greater
than the field's width, then output occurs as if there were no field
specification. The following are examples of valid format directives:

::

    %s
    %S
    %15d
    %-10=

The directives are:

- ``%s`` Prints the next format argument as a message by calling the
  function :gf:`print-message` on the format argument and the stream.
  This directive is the same as Dylan's ``%s`` format-string directive
  except for two features: (i) this module's ``%s`` directive outputs
  character objects, and (ii) you can extend the ``%s`` functionality by
  adding methods to :gf:`print-message`.
- ``%=`` Prints the next format argument by calling the :gf:`print`
  function from the Print module on the format argument and the stream.
  You can extend the ``%=`` functionality by adding methods to the
  :gf:`print-object` function from the Print module.
- ``%c`` Print the next format argument, which must be a character,
  according to Dylan's ``%s`` format-string directive. This module's
  ``%c`` directive is the same as this module's ``%s`` directive.
- ``%d`` Prints a decimal representation of the next format argument,
  which must be an integer.
- ``%b`` Prints a binary representation of the next format argument,
  which must be an integer.
- ``%o`` Prints an octal representation of the next format argument,
  which must be an integer.
- ``%x`` Prints a hexadecimal representation of the next format
  argument, which must be an integer.
- ``%m`` Invokes the next format argument, which must be a function, on
  the stream passed to :gf:`format`.
- ``%%`` Outputs a single ``%`` character.

The format Module
=================

This section contains a reference entry for each item exported from the
Format module.

.. generic-function:: format

   Outputs a control string to a stream.

   :signature: format *stream* *control-string* #rest *arguments* => ()

   :parameter stream: An instance of :class:`<stream>`. The stream to
     which formatted output should be sent.
   :parameter control-string: An instance of :drm:`<string>`. A string
     containing format directives.
   :parameter #rest arguments: Instances of :drm:`<object>`.

   :description:

     Sends output to *stream* according to the format directives in
     *control-string*. Each directive consumes one argument from
     *arguments*. See `Control strings`_ for a description of the
     control strings that can be used.

     The *control-string* contents that are not part of any directive are
     output directly to *stream*, as if by the Streams module's :gf:`write`
     function.

.. method:: format
   :specializer: <byte-string>

   Outputs a control string to a stream.

   :parameter stream: An instance of :class:`<stream>`.
   :parameter control-string: An instance of :drm:`<byte-string>`.
   :parameter #rest arguments: Instances of :drm:`<object>`.

   :description:

     There is one method for :gf:`format`, and it is specialized to
     :drm:`<byte-string>`.

.. generic-function:: format-to-string

   Returns a formatted string based on a format control string.

   :signature: format-to-string *control-string* #rest *arguments* => *result*

   :parameter control-string: An instance of :drm:`<string>`.
   :parameter #rest arguments: Instances of :drm:`<object>`.
   :value result: An instance of :drm:`<string>`.

   :description:

     Calls ``format`` to produce output according to *control-string*
     and returns the output as a string.

.. method:: format-to-string
   :specializer: <byte-string>

   Returns a formatted string based on a format control string.

   :parameter control-string: An instance of :drm:`<byte-string>`.
   :parameter #rest arguments: Instances of :drm:`<object>`.
   :value result: An instance of :drm:`<byte-string>`.

   :description:

     There is one method for :gf:`format-to-string`. The *control-string*
     argument must be a :drm:`<byte-string>`. Result is a :drm:`<byte-string>`.

.. generic-function:: print-message

   Prints an object to a stream.

   :parameter object: An instance of :drm:`<object>`.
   :parameter stream: An instance of :class:`<stream>`.

   :description:

     Prints ``object`` to ``stream``.

     Methods for this function should print objects as a message, as
     opposed to printing them in any form intending to represent Dylan
     data, literal syntax, and so on.

     For example, printing a condition object with this function
     presents the condition as an error message, but printing the
     condition object with the :gf:`print` function from the Print module
     prints the condition in some form such as::

         {Simple-error}

     See the individual methods for the details of how this function
     prints various objects. This function exists to define the behavior
     of the ``%s`` format directive and to allow users the ability to
     extend the ``%s`` directive. Users should have little need to call
     this function directly.

.. method:: print-message
   :sealed:
   :specializer: <condition>

   Prints a condition to a stream as an error message.

   :parameter condition: An instance of :drm:`<condition>`.
   :parameter stream: An instance of :class:`<stream>`.

   :description:

     Prints ``condition`` as an error message, as described for the
     Dylan ``%s`` format directive. You should not specialize the
     :gf:`print-message` protocol for subclasses of :drm:`<condition>`, but
     instead extend the :gf:`print-message` protocol to new condition
     objects by specializing methods on :gf:`report-condition`.

     .. note:: This doesn't actually work. Fix.

.. method:: print-message
   :sealed:
   :specializer: <symbol>

   Prints a symbol to a stream.

   :signature: print-message *symbol* *stream* => ()

   :parameter symbol: An instance of :drm:`<symbol>`.
   :parameter stream: An instance of :class:`<stream>`.

   :description:

   Prints ``symbol`` to ``stream`` by converting it to a string with the
   :drm:`as` function and then writing the string with the :gf:`write`
   function from the Streams module.

.. method:: print-message
   :sealed:
   :specializer: <string> or <character>

   Prints an object to a stream.

   :signature: print-message *object* *stream* => ()

   :parameter object: An instance of ``type-union(<string>, <character>)``.
   :parameter stream: An instance of ``<stream>``.

   :description:

     Prints *object* to *stream* by calling the :gf:`write` function
     from the Streams module.
