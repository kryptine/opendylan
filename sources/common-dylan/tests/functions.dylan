Module:       common-dylan-test-suite
Synopsis:     Common Dylan library test suite
Author:       Andy Armstrong
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

/// Function test cases

define test test-concatenate! ()
  let my-list = #(3, 4);
  check("test concatenate! on a list", \=, concatenate!(my-list, #(5), #(6)),
        #(3, 4, 5, 6));
  check("concatenate! should have not affected my-list", \=, my-list, #(3, 4));
  let my-stretchy-vector = make(<stretchy-vector>);
  add!(my-stretchy-vector, 3);
  add!(my-stretchy-vector, 4);
  let my-stretchy-vector-afterwards = make(<stretchy-vector>);
  add!(my-stretchy-vector-afterwards, 3);
  add!(my-stretchy-vector-afterwards, 4);
  add!(my-stretchy-vector-afterwards, 5);
  add!(my-stretchy-vector-afterwards, 6);
  check("test concatenate! on a stretchy-vector", \=,
        concatenate!(my-stretchy-vector, #(5, 6)),
        my-stretchy-vector-afterwards);
  check("concatenate! should have changed my-stretchy-vector",
        \=, my-stretchy-vector, my-stretchy-vector-afterwards);
end test;

define constant $test-error-message = "Test Error";

define class <test-error> (<error>)
end class <test-error>;

define method condition-to-string
    (error :: <test-error>) => (string :: <byte-string>)
  $test-error-message
end method condition-to-string;

define test test-condition-to-string ()
  check-equal("condition-to-string of an error produces correct string",
              condition-to-string(make(<simple-error>, format-string: "Hello")),
              "Hello");
  check-instance?("condition-to-string of a type error produces a string",
                  <string>,
                  begin
                    let error = make(<type-error>, value: 10, type: <class>);
                    condition-to-string(error)
                  end);
  check-equal("condition-to-string of an error with a condition-to-string method",
              condition-to-string(make(<test-error>)),
              $test-error-message)
end test;

define test test-debug-message ()
  check-false("debug-message doesn't crash", debug-message("Hello"));
  check-false("debug-message doesn't crash with incorrect format arguments",
              debug-message("Hello %s"));
end test;

define test test-difference ()
  //---*** Do all collections by using dylan-test-suite collection code
  let list1 = #(1, 2, 3);
  let list2 = #(3, 4, 5);
  check("test difference #1", \=, difference(list1, list2), #(1, 2));
  check("test difference #2", \=, difference(list2, list1), #(4, 5));
  check("test difference #3", \=, difference(list1, list1), #());
  check("test difference with \\>", \=, difference(list1, list2, test: \>),
        list1);
end test;

define test test-false-or ()
  let new-type = #f;
  check-instance?("False-or returns type",
                  <type>, new-type := false-or(<string>));
  check-instance?(format-to-string("%s is false-or(<string>)", "abc"),
                  new-type, "abc");
  check-instance?("#f is false-or(<string>)",
                  new-type, #f);
  check-false("#t is not false-or(<string>)",
              instance?(#t, new-type));
end test;

define test test-find-element ()
  //---*** Do all collections by using dylan-test-suite collection code
  let list1 = #("oh", "we", "like", "sheep", "like");
  check("test find-element", \=,
        find-element(list1, method (the-element) (the-element = "like") end),
        "like");
  check("test failure find-element", \=,
        find-element(list1, method (the-element) (the-element = "thermos") end),
        #f);
  check("test failure find-element with failure as symbol", \=,
        find-element(list1, method (the-element) (the-element = "thermos") end,
                     failure: #"heckfire"), #"heckfire");
  check("test find-element with skip: 1", \=,
        find-element(list1, method (the-element) (the-element = "like") end,
                     skip: 1), "like");
  check("skip: is too big", \=,
        find-element(list1, method (the-element) (the-element = "like") end,
                     skip: 2), #f);
end test;

//---*** NOTE: The <double-float> results will have to be changed if
//---*** we ever implement a better printing algorithm to get more digits
define constant $float-string-mappings
  = #(#(0.0,           "0.0"),
      #(0.0d0,         "0.0d0"),
      #(1.0,           "1.0000000"),
      #(1.0d0,         "1.0000000d0"),
      #(10.0,          "10.000000"),
      #(10.0d0,        "10.000000d0"),
      #(100.0,         "100.00000"),
      #(100.0d0,       "100.00000d0"),
      #(123456789.0,   "1.2345679s8"),
      #(123456789.0d0, "1.2345678d8"),
      // Added for bug 
      #(1.0d5,         "100000.00d0"),
      #(1.0s6,         "1000000.0"),
      #(1.0d6,         "1000000.0d0"),
      #(1.0d7,         "1.0000000d7"));

define test test-float-to-string ()
  for (float-mapping in $float-string-mappings)
    let float  = float-mapping[0];
    let string = float-mapping[1];
    check-equal(format-to-string("float-to-string(%d)", float),
                float-to-string(float), string)
  end;
  //---*** NOTE: Our runtime should catch 0.0 / 0.0 and signal an invalid
  //---***       float operation error rather than generating a {NaN}.
  check-equal("float-to-string(0.0 / 0.0)",
              float-to-string(0.0 / 0.0),
              "{NaN}");
  check-equal("float-to-string(0.0d0 / 0.0d0)",
              float-to-string(0.0d0 / 0.0d0),
              "{NaN}d0");
  //---*** NOTE: When we implement floating point exception control,
  //---***       replace the above two checks with the following:
/*
  check-equal("float-to-string(0.0 / 0.0)",
              float-to-string(with-floating-exceptions-disabled ()
                                0.0 / 0.0
                              end),
              "{NaN}");
  check-equal("float-to-string(0.0d0 / 0.0d0)",
              float-to-string(with-floating-exceptions-disabled ()
                                0.0d0 / 0.0d0
                              end),
              "{NaN}d0");
  check-equal("float-to-string(1.0 / 0.0)",
              float-to-string(with-floating-exceptions-disabled ()
                                1.0 / 0.0
                              end),
              "+{infinity}");
  check-equal("float-to-string(1.0d0 / 0.0d0)",
              float-to-string(with-floating-exceptions-disabled ()
                                1.0d0 / 0.0d0
                              end),
              "+{infinity}d0");
  check-equal("float-to-string(-1.0 / 0.0)",
              float-to-string(with-floating-exceptions-disabled ()
                                -1.0 / 0.0
                              end),
              "-{infinity}");
  check-equal("float-to-string(-1.0d0 / 0.0d0)",
              float-to-string(with-floating-exceptions-disabled ()
                                -1.0d0 / 0.0d0
                              end),
              "-{infinity}d0");
*/
end test;

define test test-ignorable ()
  assert-signals(<error>, ignorable(this-is-undefined),
                 "ignorable crashes on undefined variables");
end;

define test test-ignore ()
  assert-signals(<error>, ignore(this-is-undefined),
                 "ignore crashes on undefined variables");
end;

define constant $integer-string-mappings
  = #[#[0,     10,  "0"],
      #[1,     10,  "1"],
      #[9,     10,  "9"],
      #[1234,  10,  "1234"],
      #[10,    16,  "A"],
      #[-1,    10,  "-1"],
      #[-9,    10,  "-9"],
      #[-10,   10,  "-10"],
      #[-1234, 10,  "-1234"],
      #[-10,   16,  "-A"]];

define test test-integer-to-string ()
  for (integer-mapping in $integer-string-mappings)
    let integer = integer-mapping[0];
    let base    = integer-mapping[1];
    let string  = integer-mapping[2];
    check-equal(format-to-string("integer-to-string(%d)", integer),
                integer-to-string(integer, base: base), string)
  end;
  check-equal("integer-to-string(10, size: 6)",
              integer-to-string(10, size: 6),
              "000010");
  check-equal("integer-to-string(10, size: 6, fill: ' ')",
              integer-to-string(10, size: 6, fill: ' '),
              "    10");
  check-equal("integer-to-string(127, base: 2, size: 8)",
              integer-to-string(127, base: 2, size: 8),
              "01111111");
  check-no-errors("integer-to-string($minimum-integer)",
                  integer-to-string($minimum-integer));
  check-no-errors("integer-to-string($maximum-integer)",
                  integer-to-string($maximum-integer));
end test;

define test test-number-to-string ()
  //---*** Fill this in...
end test;

define test test-one-of ()
  let new-type = #f;
  check-instance?("one-of returns type",
                  <type>,
                  new-type := one-of(#"one", #t));
  check-instance?(format-to-string("%s is one-of(%=, #t)", #"one", #"one"),
                  new-type, #"one");
  check-instance?(format-to-string("#t is one-of(%=, #t)", #"one"),
                  new-type, #t);
  check-false(format-to-string("#f is one-of(%=, #t)", #"one"),
              instance?(#f, new-type));
end test;

define test test-position ()
  //---*** Do all collections by using dylan-test-suite collection code
  for (sequence in #[#(1, 'a', 34.43, 'a', "done"),
                     #[1, 'a', 34.43, 'a', "done"],
                     "xaxad"])
    check-equal("test position",
                position(sequence, 'a'),
                1);
    check-equal("test position with skip of 1",
                position(sequence, 'a', skip: 1),
                3);
    check-false("test position with wrong item",
                position(sequence, 'w'));
    check-false("test position with skip greater than existence",
                position(sequence, 'a', skip: 2));

    check-equal("test position with start at first",
                position(sequence, 'a', start: 1),
                1);
    check-equal("test position with start beyond first",
                position(sequence, 'a', start: 2),
                3);
    check-false("test position with end",
                position(sequence, 'a', end: 1));
    check-false("test position with skip and end",
                position(sequence, 'a', end: 3, skip: 1));
  end for;
  check-equal("test position using test: \\<",
              position(#(1, 2, 3, 4), 3, test: \<),
              3);
end test;

define test test-split ()
  // a character separator should act the same as a string separator that
  // contains only that character...
  for (separator in #('/', "/"))
    local method fmt (name)
            format-to-string("%s, sep = %=", name, separator);
          end;
    check-equal(fmt("split empty string"),
                split("", separator),
                #[""]);
    check-equal(fmt("split single character"),
                split("a", separator),
                #["a"]);
    check-equal(fmt("split two characters"),
                split("a/b", separator),
                #["a", "b"]);
    check-equal(fmt("split multiple single characters"),
                split("a/b/c/d/e/f/g", separator),
                #["a", "b", "c", "d", "e", "f", "g"]);
    check-equal(fmt("split single word"),
                split("hello", separator),
                #["hello"]);
    check-equal(fmt("split two words"),
                split("hello/world", separator),
                #["hello", "world"]);
    check-equal(fmt("split three words"),
                split("major/minor/build", separator),
                #["major", "minor", "build"]);
    check-equal(fmt("split multiple words"),
                split("x=100/y=200/width=30/height=10", separator),
                #["x=100", "y=200", "width=30", "height=10"]);
    check-equal(fmt("split only the separator character"),
                split("/", separator),
                #["", ""]);
    check-equal(fmt("split a/"),
                split("a/", separator),
                #["a", ""]);
    check-equal(fmt("split /b"),
                split("/b", separator),
                #["", "b"]);
    check-equal(fmt("split with double separator"),
                split("major//build", separator),
                #["major", "", "build"]);
    check-equal(fmt("split with spaces"),
                split(" major / minor / build ", separator),
                #[" major ", " minor ", " build "]);
    check-equal(fmt("split with start"),
                split("123456789/123456789", separator, start: 1),
                #["23456789", "123456789"]);
    check-equal(fmt("split with end"),
                split("012/456789", separator, end: 8),
                #["012", "4567"]);
    check-equal(fmt("split with start and end"),
                split("012/456789", separator, start: 2, end: 8),
                #["2", "4567"]);
    check-equal(fmt("split with count"),
                split("1/2/3/4", separator, count: 2),
                #["1", "2/3/4"]);
    check-equal(fmt("split with count and start"),
                split("1/2/3/4", separator, count: 2, start: 2),
                #["2", "3/4"]);
    check-equal(fmt("split with count and end"),
                split("1/2/3/4", separator, count: 2, end: 5),
                #["1", "2/3"]);
    check-equal(fmt("split with count, start, and end"),
                split("1/2/3/4", separator, count: 2, start: 2, end: 5),
                #["2", "3"]);
    check-equal(fmt("split with count = 1"),
                split("a/b/c/d", separator, count: 1),
                #["a/b/c/d"]);
    check-equal(fmt("split with remove-if-empty?: #t"),
                split("/a/b/", separator, remove-if-empty?: #t),
                #["a", "b"]);
    check-equal(fmt("split with remove-if-empty?: #t and separator only"),
                split("/", separator, remove-if-empty?: #t),
                #[]);
    check-equal(fmt("split with remove-if-empty?: #t and separators only"),
                split("///", separator, remove-if-empty?: #t),
                #[]);
    check-equal(fmt("split with remove-if-empty?: #t and start, only separator"),
                split("a/", separator, start: 1, remove-if-empty?: #t),
                #[]);
    check-equal(fmt("split with remove-if-empty?: #t and start"),
                split("/a", separator, start: 1, remove-if-empty?: #t),
                #["a"]);
    check-equal(fmt("split with remove-if-empty?: #t and end, only separator"),
                split("/a", separator, end: 1, remove-if-empty?: #t),
                #[]);
    check-equal(fmt("split with remove-if-empty?: #t and end"),
                split("a/", separator, end: 1, remove-if-empty?: #t),
                #["a"]);
    check-equal(fmt("split with remove-if-empty?: #t and count"),
                split("/a/b", separator, count: 1, remove-if-empty?: #t),
                #["a/b"]);
    check-equal(fmt("split with remove-if-empty?: #t and count, only separator character"),
                split("/", separator, count: 1, remove-if-empty?: #t),
                #[]);
    check-equal(fmt("split with test"),
                split("a/", separator, test: \~==),
                #["", "/"]);
    check-equal(fmt("split with separator not found"),
                split("abc", "x"),
                #["abc"]);
  end for;

  check-condition("split with empty separator signals?",
                  <error>,
                  split("abc", ""));
  check-condition("split with splitter that returns same indices signals?",
                  <error>,
                  split("abc", method (_, bpos, _) values(bpos, bpos) end));
  check-equal("split with separator crossing start:",
              split("xxx one xxx two xxx", "xxx", start: 1),
              #["xx one ", " two ", ""]);
  check-equal("split with separator crossing end:",
              split("xxx one xxx two xxx", "xxx", end: 17),
              #["", " one ", " two x"]);
  check-equal("split with separator crossing start: and end:",
              split("xxx one xxx two xxx", "xxx", start: 1, end: 17),
              #["xx one ", " two x"]);
end test;

define benchmark benchmark-split ()
  local
    // Would be nice to provide this separator function in common-dylan, or to
    // provide an easy way to make a separator function from
    // strings/whitespace? or from a set of elements or...
    method find-whitespace
        (big :: <string>, bpos :: <integer>, epos :: <integer>)
     => (bpos :: false-or(<integer>), _end :: false-or(<integer>))
      iterate loop (pos = bpos, start = #f)
        if (member?(big[pos], " \t"))
          loop(pos + 1, pos)
        elseif (start)
          values(start, pos)
        end                 // else values(#f, #f)
      end
    end method;
  benchmark-repeat(iterations: 1000)
    split("The quick brown fox jumps over the lazy dog.", find-whitespace);
  end;
end benchmark;

define test test-join ()
  let abc = #("a", "b", "c");
  for (separator in #("blah", #[1], #(1)),
       expected in #("", #[], #()))
    check-equal("join empty sequence return type",
                join(#[], separator),
                expected);
  end;
  check-equal("basic join",
              "a, b, c",
              join(abc, ", "));
  check-equal("join of one element",
              "singleton",
              join(#("singleton"), " "));
  check-equal("join with conjunction",
              "a, b and c",
              join(abc, ", ",
                   conjunction: " and "));
  check-equal("join with key",
              "1, 2, 3",
              join(#(1, 2, 3), ", ",
                   key: integer-to-string));
  check-equal("join with conjunction and key",
              "1, 2 and 3",
              join(#(1, 2, 3), ", ",
                   conjunction: " and ",
                   key: integer-to-string));
end test;

define test test-remove-all-keys! ()
  //---*** Do all collections by using dylan-test-suite collection code
end test;

define test test-string-to-integer ()
  for (integer-mapping in $integer-string-mappings)
    let integer = integer-mapping[0];
    let base    = integer-mapping[1];
    let string  = integer-mapping[2];
    check-equal(format-to-string("string-to-integer(%s)", string),
                string-to-integer(string, base: base), integer)
  end;
  check-no-errors("string-to-integer of minimum integer",
                  string-to-integer(integer-to-string($minimum-integer)));
  check-no-errors("string-to-integer of maximum integer",
                  string-to-integer(integer-to-string($maximum-integer)));
end test;

define test test-subclass ()
  let new-type = #f;
  check-instance?("subclass returns type",
                  <type>,
                  new-type := subclass(<string>));
  check-instance?(format-to-string("<string> is subclass(<string>)"),
                  new-type, <string>);
  check-instance?(format-to-string("<byte-string> is subclass(<string>)"),
                  new-type, <byte-string>);
  check-false(format-to-string("<object> is not subclass(<string>)"),
              instance?(<object>, new-type));
end test;

define test test-fill-table! ()
  let table = make(<table>);
  check-equal("fill-table(...) returns the table",
              fill-table!(table, #[0, "Zero", 1, "One"]),
              table);
  check-equal("table(...)[0] = \"Zero\"",
              table[0], "Zero");
  check-equal("table(...)[1] = \"One\"",
              table[1], "One");
end test;

// Application startup handling

define test test-application-name ()
  check-instance?("application-name returns #f or a string",
                  false-or(<string>), application-name());
end test;

define test test-application-filename ()
  let filename = application-filename();
  check-true("application-filename returns #f or a valid, existing file name",
             ~filename | file-exists?(filename));
end test;

define test test-application-arguments ()
  check-instance?("application-arguments returns a sequence",
                  <sequence>, application-arguments());
end test;

define test test-tokenize-command-line ()
  //---*** Fill this in...
end test;

define test test-exit-application ()
  //---*** Fill this in...
end test;

define test test-register-application-exit-function ()
  //---*** Fill this in...
end test;

define test test-unfound ()
  //---*** Fill this in...
end test;

define test test-unfound? ()
  check-true("unfound?($unfound)", unfound?($unfound));
  check-false("unfound?(#f) == #f", unfound?(#f));
  check-false("unfound?(#t) == #f", unfound?(#t));
end test;

define test test-found? ()
  check-false("found?($unfound) is false", found?($unfound));
  check-true("found?(#f)", found?(#f));
  check-true("found?(#t)", found?(#t));
end test;

define test test-unsupplied ()
  //---*** Fill this in...
end test;

define test test-unsupplied? ()
  check-true("unsupplied?($unsupplied)", unsupplied?($unsupplied));
  check-false("unsupplied?(#f) == #f", unsupplied?(#f));
  check-false("unsupplied?(#t) == #f", unsupplied?(#t));
end test;

define test test-supplied? ()
  //---*** Fill this in...
end test;

define test test-true? ()
  //---*** Fill this in...
end test;

define test test-false? ()
  //---*** Fill this in...
end test;


/// simple-format module

define test test-format-out ()
  check-false("format-out doesn't crash", format-out("Hello"));
  check-condition("format-out crashes when missing an argument",
                  <error>, format-out("Hello %s"));
  check-condition("format-out crashes with argument of wrong type",
                  <error>, format-out("Hello %c", 10));
  check-condition("format-out crashes with invalid directive %z",
                  <error>, format-out("Hello %z", 10));
end test;

define test test-format-to-string ()
  check-instance?("format-to-string returns a string",
                  <string>,
                  format-to-string("Hello"));
  check-condition("format-to-string crashes when missing an argument",
                  <error>, format-to-string("Hello %s"));
  check-condition("format-to-string crashes with argument of wrong type",
                  <error>, format-to-string("Hello %c", 10));
  check-condition("format-to-string crashes with invalid directive %z",
                  <error>, format-to-string("Hello %z", 10));
  check-equal("format-to-string(\"%d\", 10)",
              format-to-string("%d", 10),
              "10");
  check-equal("format-to-string(\"%b\", 7)",
              format-to-string("%b", 7),
              "111");
  check-equal("format-to-string(\"%o\", 16)",
              format-to-string("%o", 16),
              "20");
  check-equal("format-to-string(\"%x\", 257)",
              format-to-string("%x", 257),
              "101");
  check-equal("format-to-string(\"%c\", 'a')",
              format-to-string("%c", 'a'),
              "a");
  check-equal("format-to-string(\"%%\")",
              format-to-string("%%"),
              "%");
  format-object-tests();
  format-function-tests();
end test;

define constant $format-object-mappings
  = vector(vector(10, "10", "10"),
           vector('a', "a", "'a'"),
           vector('Z', "Z", "'Z'"),
           vector(#"symbol", "#\"symbol\""),
           vector(#"symbol", "#\"symbol\""),
           vector(#f, "#f"),
           vector(#t, "#t"),
           vector(<object>, "<object>", "{<class>: <object>}"),
           vector(find-key, "find-key", "{<incremental-generic-function>: find-key}"),
           vector("10", "10", "\"10\""));

define constant $format-complex-object-mappings
  = vector(vector(#(), "size 0"),
           vector(pair(1, 2), "1, 2"),
           vector(range(from: 0, to: 10), "0 to 10"),
           vector(range(from: 10, to: 1, by: -1), "10 to 1 by -1"),
           vector(range(from: 10, by: -1), "10 by -1"),
           vector(make(<array>, dimensions: #(2, 3)), "2 x 3"),
           vector(as(<vector>, #(1, 'a', "Hello")),
                  "1, 'a', \"Hello\""),
           vector(singleton(10), "10"),
           vector(type-union(<integer>, <string>),
                  "<integer>, <string>"),
           vector(type-union(singleton(#f), <string>),
                  "#f, <string>"));

define function test-print-name
    (object, pretty-name :: <string>, unique-name :: <string>)
 => ()
  check-equal(format-to-string("format-to-string(\"%%s\", %s)", unique-name),
              format-to-string("%s", object),
              pretty-name);
  check-equal(format-to-string("format-to-string(\"%%=\", %s)", unique-name),
              format-to-string("%=", object),
              unique-name);
end function test-print-name;

define function format-object-tests
    () => ()
  for (mapping in $format-object-mappings)
    let object = mapping[0];
    let pretty-name = mapping[1];
    let unique-name = if (size(mapping) = 3) mapping[2] else pretty-name end;
    test-print-name(object, pretty-name, unique-name)
  end;
  for (mapping in $format-complex-object-mappings)
    let object = mapping[0];
    let class-name = format-to-string("%s", object-class(object));
    let unique-name = format-to-string("{%s: %s}", class-name, mapping[1]);
    test-print-name(object, unique-name, unique-name)
  end;
  let type = type-union(<string>, type-union(singleton(10), <character>));
  let class-name = format-to-string("%s", object-class(type));
  let expected-name
    = format-to-string("{%s: <string>, {%s: 10, <character>}}",
                       class-name, class-name);
  test-print-name(type, expected-name, expected-name)
end function format-object-tests;

define generic test-print-1 () => ();
define generic test-print-2 ();
define generic test-print-3 (a :: <integer>) => num;
define generic test-print-4 (a :: <number>, #rest args) => (num :: <integer>);
define generic test-print-5 (a :: <string>, #key test) => (num :: <integer>, #rest vals);
define generic test-print-6 (a :: <string>, #key #all-keys) => (#rest vals :: <string>);
define generic test-print-7 (a :: subclass(<string>)) => ();
define generic test-print-8 (a :: false-or(<string>)) => ();
define generic test-print-9 (a :: type-union(<integer>, <float>)) => ();
define generic test-print-10 (a :: one-of(#"a", #"b")) => ();
define generic test-print-11
    (a :: limited(<integer>, min: 0), b :: limited(<integer>, max: 64))
 => (c :: limited(<integer>, min: 0, max: 64));
define generic test-print-12
    (a :: limited(<vector>, of: <float>),
     b :: limited(<vector>, of: <double-float>, size: 4))
 => (c :: false-or(limited(<array>, of: <float>, dimensions: #[2, 2])));

define method test-print-1 () => ()
end method test-print-1;

define method test-print-2 ()
end method test-print-2;

define method test-print-3 (a :: <integer>) => (num)
  #f
end method test-print-3;

define method test-print-4 (a :: <number>, #rest args) => (num :: <integer>)
  0
end method test-print-4;

define method test-print-5 (a :: <string>, #key test) => (num :: <integer>, #rest vals)
  0
end method test-print-5;

define method test-print-6 (a :: <string>, #key #all-keys) => (#rest vals :: <string>)
end method test-print-6;

define method test-print-7 (a :: subclass(<string>)) => ()
end method test-print-7;

define method test-print-8 (a :: false-or(<string>)) => ()
end method test-print-8;

define method test-print-9 (a :: type-union(<integer>, <float>)) => ()
end method test-print-9;

define method test-print-10 (a :: one-of(#"a", #"b")) => ()
end method test-print-10;

define method test-print-11
    (a :: limited(<integer>, min: 0), b :: limited(<integer>, max: 64))
 => (c :: limited(<integer>, min: 0, max: 64))
  0
end method test-print-11;

define method test-print-12
    (a :: limited(<vector>, of: <float>),
     b :: limited(<vector>, of: <double-float>, size: 4))
 => (c :: false-or(limited(<array>, of: <float>, dimensions: #[2, 2])))
  #f
end method test-print-12;

define constant $format-function-mappings
  = vector(vector(test-print-1,
                  "{<sealed-generic-function>: test-print-1}",
                  "{<simple-method>: ??? () => ()}"),
           vector(test-print-2,
                  "{<sealed-generic-function>: test-print-2}",
                  "{<simple-method>: ??? () => (#rest)}"),
           vector(test-print-3,
                  "{<sealed-generic-function>: test-print-3}",
                  "{<simple-method>: ??? (<integer>) => (<object>)}"),
           vector(test-print-4,
                  "{<sealed-generic-function>: test-print-4}",
                  "{<simple-method>: ??? (<number>, #rest) => (<integer>)}"),
           vector(test-print-5,
                  "{<sealed-generic-function>: test-print-5}",
                  "{<keyword-method>: ??? (<string>, #key test:) => (<integer>, #rest)}"),
           vector(test-print-6,
                  "{<sealed-generic-function>: test-print-6}",
                  "{<keyword-method>: ??? (<string>, #key #all-keys) => (#rest <string>)}"),
           vector(test-print-7,
                  "{<sealed-generic-function>: test-print-7}",
                  "{<simple-method>: ??? (subclass(<string>)) => ()}"),
           vector(test-print-8,
                  "{<sealed-generic-function>: test-print-8}",
                  "{<simple-method>: ??? (false-or(<string>)) => ()}"),
           vector(test-print-9,
                  "{<sealed-generic-function>: test-print-9}",
                  "{<simple-method>: ??? (type-union(<integer>, <float>)) => ()}"),
           vector(test-print-10,
                  "{<sealed-generic-function>: test-print-10}",
                  "{<simple-method>: ??? (one-of(#\"a\", #\"b\")) => ()}"),
           vector(test-print-11,
                  "{<sealed-generic-function>: test-print-11}",
                  "{<simple-method>: ??? (limited(<integer>, min: 0), limited(<integer>, max: 64)) => (limited(<integer>, min: 0, max: 64))}"),
           vector(test-print-12,
                  "{<sealed-generic-function>: test-print-12}",
                  "{<simple-method>: ??? (limited(<simple-vector>, of: <float>), limited(<simple-vector>, of: <double-float>, size: 4)) => (false-or(limited(<array>, of: <float>, dimensions: #[2, 2])))}"));

define function format-function-tests
    () => ()
  for (mapping in $format-function-mappings)
    let gf = mapping[0];
    let gf-expected-text = mapping[1];
    check-equal(format-to-string("format-to-string(\"%%=\", %s)", gf-expected-text),
                format-to-string("%=", gf),
                gf-expected-text);
    let meth = generic-function-methods(gf).first;
    let meth-expected-text = mapping[2];
    check-equal(format-to-string("format-to-string(\"%%=\", %s)", meth-expected-text),
                format-to-string("%=", meth),
                meth-expected-text);
  end for;
end function format-function-tests;


/// simple-random tests

/*---*** andrewa: not used yet...
define method chi-square
    (N :: <integer>, range :: <integer>) => (chi-square :: <integer>)
  let f = make(<simple-object-vector>, size: range, fill: 0);
  for (i from 0 below N)
    let rand = random(range);
    f[rand] := f[rand] + 1;
  end;
  let t = 0;
  for (i from 0 below range) t := t + f[i] * f[i] end;
  floor/(range * t, N) - N
end method chi-square;
*/

define test test-random ()
  // We should use chi-square somehow, but we don't want it to be slow.
  // Also, what value should it be returning?
  //---*** Fill this in...
end test;


/// simple-profiling tests

define test test-start-profiling ()
  //---*** Fill this in...
end test;

define test test-start-profiling-type ()
  //---*** Fill this in...
end test;

define test test-stop-profiling ()
  //---*** Fill this in...
end test;

define test test-stop-profiling-type ()
  //---*** Fill this in...
end test;

define test test-profiling-type-result ()
  //---*** Fill this in...
end test;


/// finalization tests

define test test-drain-finalization-queue ()
  //---*** Fill this in...
end test;

define test test-finalize ()
  //---*** Fill this in...
end test;

define test test-finalize-when-unreachable ()
  //---*** Fill this in...
end test;

define test test-automatic-finalization-enabled?-setter ()
  //---*** Fill this in...
end test;

define test test-automatic-finalization-enabled? ()
  //---*** Fill this in...
end test;


/// Numerics

define test test-integer-length ()
  for (i from 0 below 27)
    let v1 = ash(1, i) - 1;
    check-equal(format-to-string("integer-length(%d) is %d", v1, i),
                i, integer-length(v1));

    let v2 = ash(1, i);
    check-equal(format-to-string("integer-length(%d) is %d", v2, i + 1),
                i + 1, integer-length(v2));

    let v3 = - ash(1, i);
    check-equal(format-to-string("integer-length(%d) is %d", v3, i),
                i, integer-length(v3));

    let v4 = -1 - ash(1, i);
    check-equal(format-to-string("integer-length(%d) is %d", v4, i + 1),
                i + 1, integer-length(v4));
  end for;
end test;

// Ensure that a number is written to memory in order to dispose of
// any hidden bits in floating-point intermediate values

define variable *temp* :: <float> = 0.0;

define not-inline function store-float (x :: <float>) => (the-x :: <float>)
  *temp* := x;
  sequence-point();
  *temp*;
end function;

// TODO(cgay): separate into multiple tests instead with-test-unit, which is a no-op.
define test test-float-radix ()
  // Based on the algorithm in:
  //   Malcolm, M. A. Algorithms to reveal properties of floating-point
  //   arithmetic. Comm. ACM 15, 11 (Nov. 1972), 949-951.
  //   http://doi.acm.org/10.1145/355606.361870
  // with improvements (namely the use of store-float) suggested in:
  //   Gentlemen, W. Morven, Scott B. Marovich. More on algorithms
  //   that reveal properties of floating point arithmetic units.
  //   Comm. ACM 17, 5 (May 1974), 276-277.
  //   http://doi.acm.org/10.1145/360980.361003

  with-test-unit ("float-radix on <single-float>")
    // Test successive powers of two until we find the first one in
    // the region where integers are no longer exactly representable
    let a :: <single-float>
      = for (a :: <single-float> = 1.0s0 then a + a,
             while: store-float(store-float(a + 1.0s0) - a) = 1.0s0)
        finally
          a
        end for;
    // Add successive powers of two to a until we find the successor
    // floating point number beyond a; a and its successor differ by
    // beta
    let ibeta :: <integer>
      = for (b :: <single-float> = 1.0s0 then b + b,
             while: zero?(store-float(store-float(a + b) - a)))
        finally
          floor(store-float(store-float(a + b) - a))
        end;

    check-equal("float-radix for <single-float> matches ibeta",
                ibeta, float-radix(1.0s0));
  end with-test-unit;

  with-test-unit ("float-radix on <double-float>")
    // Test successive powers of two until we find the first one in
    // the region where integers are no longer exactly representable
    let a :: <double-float>
      = for (a :: <double-float> = 1.0d0 then a + a,
             while: store-float(store-float(a + 1.0d0) - a) = 1.0d0)
        finally
          a
        end for;
    // Add successive powers of two to a until we find the successor
    // floating point number beyond a; a and its successor differ by
    // beta
    let ibeta :: <integer>
      = for (b :: <double-float> = 1.0d0 then b + b,
             while: zero?(store-float(store-float(a + b) - a)))
        finally
          floor(store-float(store-float(a + b) - a))
        end;

    check-equal("float-radix for <double-float> matches ibeta",
                ibeta, float-radix(1.0d0));
  end with-test-unit;
end test;

define test test-float-digits ()
  check-true("float-digits(1.0d0) is at least as much as float-digits(1.0s0)",
             float-digits(1.0d0) >= float-digits(1.0s0));
end test;

define test test-float-precision ()
  check-true("float-precision(0.0s0) is zero", zero?(float-precision(0.0s0)));
  check-true("float-precision(0.0d0) is zero", zero?(float-precision(0.0d0)));
  check-equal("float-precision and float-digits are the same"
                " for normalized single floats",
              float-precision(1.0s0), float-digits(1.0s0));
  check-equal("float-precision and float-digits are the same"
                " for normalized double floats",
              float-precision(1.0d0), float-digits(1.0d0));
end test;

// TODO(cgay): separate into multiple tests instead with-test-unit, which is a no-op.
define test test-decode-float ()
  let single-beta :: <single-float> = as(<single-float>, float-radix(1.0s0));

  with-test-unit ("decode-float of <single-float> radix")
    let (significand :: <single-float>,
         exponent :: <integer>,
         sign :: <single-float>) = decode-float(single-beta);
    check-equal("significand for <single-float> radix = 1 / radix",
                1.0s0 / single-beta, significand);
    check-equal("exponent for <single-float> radix = 2",
                2, exponent);
    check-equal("sign for <single-float> radix = 1.0s0",
                1.0s0, sign);
  end with-test-unit;

  with-test-unit ("decode-float of <single-float> subnormal")
    let single-subnormal :: <single-float> = encode-single-float(as(<machine-word>, #x1));
    let (significand :: <single-float>,
         exponent :: <integer>,
         sign :: <single-float>) = decode-float(single-subnormal);
    check-equal("significand for <single-float> subnormal = 1 / radix",
                1.0s0 / single-beta, significand);
    check-equal("exponent for <single-float> subnormal = -148",
                -148, exponent);
    check-equal("sign for <single-float> subnormal = 1.0s0",
                1.0s0, sign);
  end with-test-unit;

  let double-beta :: <double-float> = as(<double-float>, float-radix(1.0d0));

  with-test-unit ("decode-float of <double-float> radix")
    let (significand :: <double-float>,
         exponent :: <integer>,
         sign :: <double-float>) = decode-float(double-beta);
    check-equal("significand for <double-float> radix = 1 / radix",
                1.0d0 / double-beta, significand);
    check-equal("exponent for <double-float> radix = 2",
                2, exponent);
    check-equal("sign for <double-float> radix = 1.0d0",
                1.0d0, sign);
  end with-test-unit;

  with-test-unit ("decode-float of <double-float> subnormal")
    let double-subnormal :: <double-float> =
      encode-double-float(as(<machine-word>, #x1),
                          as(<machine-word>, #x0));
    let (significand :: <double-float>,
         exponent :: <integer>,
         sign :: <double-float>) = decode-float(double-subnormal);
    check-equal("significand for <double-float> subnormal = 1 / radix",
                1.0d0 / double-beta, significand);
    check-equal("exponent for <double-float> subnormal = -1073",
                -1073, exponent);
    check-equal("sign for <double-float> subnormal = 1.0d0",
                1.0d0, sign);
  end with-test-unit;
  with-test-unit ("decode-float of <double-float> negative subnormal")
    let double-subnormal :: <double-float> =
      encode-double-float(as(<machine-word>, #x0),
                          as(<machine-word>, #x80000001));
    let (significand :: <double-float>,
         exponent :: <integer>,
         sign :: <double-float>) = decode-float(double-subnormal);
    check-equal("significand for <double-float> negative subnormal = 1 / radix",
                1.0d0 / double-beta, significand);
    check-equal("exponent for <double-float> negative subnormal = -1041",
                -1041, exponent);
    check-equal("sign for <double-float> negative subnormal = -1.0d0",
                -1.0d0, sign);
  end with-test-unit;

end test;

define test test-scale-float ()
  check-equal("scale-float(1.0s0, 1) is float-radix(1.0s0)",
              as(<single-float>, float-radix(1.0s0)),
              scale-float(1.0s0, 1));
  check-equal("scale-float(-1.0s0, 1) is -float-radix(1.0s0)",
              as(<single-float>, -float-radix(1.0s0)),
              scale-float(-1.0s0, 1));
  check-equal("scale-float(1.0d0, 1) is float-radix(1.0d0)",
              as(<double-float>, float-radix(1.0d0)),
              scale-float(1.0d0, 1));
  check-equal("scale-float(-1.0d0, 1) is -float-radix(1.0d0)",
              as(<double-float>, -float-radix(1.0d0)),
              scale-float(-1.0d0, 1));
end test;

define inline function classify-single-float (bits)
 => (classification :: <float-classification>)
  classify-float(encode-single-float(as(<machine-word>, bits)))
end function classify-single-float;

define inline function classify-double-float (low-bits, high-bits)
 => (classification :: <float-classification>)
  classify-float(encode-double-float(as(<machine-word>, low-bits),
                                     as(<machine-word>, high-bits)))
end function classify-double-float;

// These values came from http://www.astro.umass.edu/~weinberg/a732/notes07_01.pdf
define test test-classify-float ()
  assert-equal(classify-single-float(#x00000000), #"zero");
  assert-equal(classify-single-float(#x80000000), #"zero");
  assert-equal(classify-single-float(#x7f800000), #"infinite");
  assert-equal(classify-single-float(#xff800000), #"infinite");
  assert-equal(classify-single-float(#x00000001), #"subnormal");
  assert-equal(classify-single-float(#x007fffff), #"subnormal");
  assert-equal(classify-single-float(#x00800000), #"normal");
  assert-equal(classify-single-float(#x7f7fffff), #"normal");
  assert-equal(classify-single-float(#x7fc00000), #"nan");

  assert-equal(classify-double-float(#x00000000, #x00000000), #"zero");
  assert-equal(classify-double-float(#x00000000, #x80000000), #"zero");
  assert-equal(classify-double-float(#x00000000, #x7ff00000), #"infinite");
  assert-equal(classify-double-float(#x00000000, #xfff00000), #"infinite");
  assert-equal(classify-double-float(#x00000001, #x00000000), #"subnormal");
  assert-equal(classify-double-float(#xffffffff, #x000fffff), #"subnormal");
  assert-equal(classify-double-float(#x00000000, #x00100000), #"normal");
  assert-equal(classify-double-float(#xffffffff, #x7fefffff), #"normal");
  assert-equal(classify-double-float(#x00000000, #x7ff80000), #"nan");
end test;

define suite common-dylan-functions-test-suite ()
  test test-concatenate!;
  test test-condition-to-string;
  test test-debug-message;
  test test-difference;
  test test-false-or;
  test test-find-element;
  test test-float-to-string;
  test test-ignorable;
  test test-ignore;
  test test-integer-to-string;
  test test-number-to-string;
  test test-one-of;
  test test-position;
  test test-split;
  test test-join;
  test test-remove-all-keys!;
  test test-string-to-integer;
  test test-subclass;
  test test-fill-table!;
  test test-application-name;
  test test-application-filename;
  test test-application-arguments;
  test test-tokenize-command-line;
  test test-exit-application;
  test test-register-application-exit-function;
  test test-unfound;
  test test-unfound?;
  test test-found?;
  test test-unsupplied;
  test test-unsupplied?;
  test test-supplied?;
  test test-true?;
  test test-false?;
  test test-format-out;
  test test-format-to-string;
  test test-random;
  test test-start-profiling;
  test test-start-profiling-type;
  test test-stop-profiling;
  test test-stop-profiling-type;
  test test-profiling-type-result;
  test test-drain-finalization-queue;
  test test-finalize;
  test test-finalize-when-unreachable;
  test test-automatic-finalization-enabled?-setter;
  test test-automatic-finalization-enabled?;
  test test-integer-length;
  test test-float-radix;
  test test-float-digits;
  test test-float-precision;
  test test-decode-float;
  test test-scale-float;
  test test-classify-float;
end;
