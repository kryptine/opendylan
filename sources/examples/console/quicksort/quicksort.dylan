Module:    quicksort
Synopsis:  Quicksort example
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

// To see the different optimizations performed on each version of quicksort
// in this file, compile this example in "production mode" and then select
// Color Dispatch Optimizations from the editor's View menu.  See
// https://opendylan.org/documentation/getting-started-ide/coloring.html

// No type declarations except for the input sequence, v.
define method sequence-quicksort
    (v :: <sequence>) => (sorted-v :: <sequence>)
  local method exchange (m, n) => ()
	  let t = v[m];
	  v[m] := v[n];
	  v[n] := t
	end method exchange,
        method partition (lo, hi, x) => (i, j)
	  let i = for (i from lo to hi, while: v[i] < x)
		  finally i
		  end;
	  let j = for (j from hi to lo by -1, while: x < v[j])
		  finally j
		  end;
	  if (i <= j)
	    exchange(i, j);
	    partition(i + 1, j - 1, x)
	  else
	    values(i, j)
	  end
	end method partition,
        method sort (lo, hi) => ()
	  if (lo < hi)
	    let (i, j) = partition(lo, hi, v[round/(lo + hi, 2)]);
	    sort(lo, j);
	    sort(i, hi)
	  end
	end method sort;
  sort(0, v.size - 1);
  v
end method sequence-quicksort;

// With type declarations for the sequence and its indices.
define method sequence-quicksort-typed
    (v :: <sequence>) => (sorted-v :: <sequence>)
  local method exchange (m :: <integer>, n :: <integer>) => ()
	  let t = v[m];
	  v[m] := v[n];
	  v[n] := t
	end method exchange,
        method partition
            (lo :: <integer>, hi :: <integer> , x)
         => (i :: <integer>, j :: <integer>)
	  let i :: <integer>
            = for (i :: <integer> from lo to hi, while: v[i] < x)
              finally i
              end;
	  let j :: <integer>
            = for (j :: <integer> from hi to lo by -1, while: x < v[j])
              finally j
              end;
	  if (i <= j)
	    exchange(i, j);
	    partition(i + 1, j - 1, x)
	  else
	    values(i, j)
	  end
	end method partition,
        method sort (lo :: <integer>, hi :: <integer>) => ()
	  when (lo < hi)
	    let (i, j) = partition(lo, hi, v[round/(lo + hi, 2)]);
	    sort(lo, j);
	    sort(i, hi)
	  end;
	end method sort;
  sort(0, v.size - 1);
  v
end method sequence-quicksort-typed;

define constant <integer-vector> = limited(<vector>, of: <integer>);

// Non-polymorphic version -- only sorts vectors of integers.
define method integer-vector-quicksort
    (v :: <integer-vector>) => (sorted-v :: <integer-vector>)
  local method exchange (m :: <integer>, n :: <integer>) => ()
	  let t = v[m];
	  v[m] := v[n];
	  v[n] := t
	end method exchange,
        method partition
	    (lo :: <integer>, hi :: <integer> , x :: <integer>)
	 => (i :: <integer>, j :: <integer>)
	  let i :: <integer>
	    = for (i :: <integer> from lo to hi, while: v[i] < x)
	      finally i
	      end;
	  let j :: <integer>
	    = for (j :: <integer> from hi to lo by -1, while: x < v[j])
	      finally j
	      end;
	  if (i <= j)
	    exchange(i, j);
	    partition(i + 1, j - 1, x)
	  else
	    values(i, j)
	  end
	end method partition,
        method sort (lo :: <integer>, hi :: <integer>) => ()
	  when (lo < hi)
	    let (i, j) = partition(lo, hi, v[round/(lo + hi, 2)]);
	    sort(lo, j);
	    sort(i, hi)
	  end;
	end method sort;
  sort(0, v.size - 1);
  v
end method integer-vector-quicksort;

define method main () => ()
  let args = application-arguments();
  let data = vector("My dog has fleas.",
                    vector("My", "dog", "has", "fleas"),
                    vector('m', 'd', 'h', 'f'),
                    vector(2, 4, 1, 3));
  // Show off polymorphism...
  map(method (v)
        display-sequence(v);
        format-out(" sorted is ");
        display-sequence(sequence-quicksort(v));
        format-out("\n");
      end,
      data);
  // Show differences in speed...
  let default-size = 50000;
  local method warn-and-default () => (default-size)
          format-out("*** Invalid argument specified.  Using default value. ***\n");
          default-size
        end;
  let n = if (args.size > 0)
	    block ()
              let x = string-to-integer(application-arguments()[0]);
              if (x < 0)
                warn-and-default()
              else
                x
              end
            exception (<error>)
              warn-and-default()
            end block
          else
            default-size
          end;
  let orig :: <integer-vector> = make(<integer-vector>, size: n);
  let data :: <integer-vector> = make(<integer-vector>, size: n);
  for (i :: <integer> from 0 below n)
    orig[i] := random($maximum-integer);
  end;
  for (function in vector(sequence-quicksort,
                          sequence-quicksort-typed,
                          integer-vector-quicksort),
       typename in #["<sequence>", "<sequence> (with type decls)",
                     "<integer-vector>"])
    map-into(data, identity, orig);  // Unsort data.
    format-out("Sorting a %d element %s...", n, typename);
    let (seconds, microseconds) = timing ()
                                    function(data);
                                  end;
    format-out("took %d.%s seconds\n",
               seconds, integer-to-string(microseconds, size: 6));
  end;
end method main;

// Display a sequence nicely
define method display-sequence (s :: <sequence>)
  format-out("#[");
  let length :: <integer> = size(s);
  for (elem in s, i from 1)
    format-out("%s%s", elem, if (i < length) ", " else "" end);
  end for;
  format-out("]");
end;

// Strings already display nicely, so don't make them worse.
define method display-sequence (s :: <string>)
  format-out("%=", s);
end;

begin
  main();
end;
