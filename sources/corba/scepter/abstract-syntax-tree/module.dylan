Module:    scepter-ast
Author:    Jason Trenouth
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define class <ast-module> (<ast-declarator>, <scope>)
end class;

define method can-be-redefined? (module :: <ast-module>)
  #t;
end method;

define method check-before-add (module :: <ast-module>, interface :: <ast-interface>)
  let prior-declarator = resolve-identifier(module, interface.declarator-local-name);
  if (prior-declarator)
    case
      (~ interface-defined?(prior-declarator)) =>
        if (~ prior-declarator.declarator-scope == module)
          error(make(<idl-scope-conflict>, declarators: vector(prior-declarator, interface, module)));
        end if;
      (referenced?(module, prior-declarator)) =>
        error(make(<idl-redefinition-after-use>, declarators: vector(interface, module, prior-declarator)));
    end case;
  end if;
end method;

define method check-before-add (module :: <ast-module>, interface :: <ast-forward-interface>)
  let prior-declarator = resolve-identifier(module, interface.declarator-local-name);
  if (prior-declarator & prior-declarator.declarator-scope == module)
      interface.full-definition := prior-declarator;
  else
    next-method();
  end if;
end method;

define method check-before-add (module :: <ast-module>, struct :: <ast-structure>)
  let prior-declarator
    = resolve-identifier(module, struct.declarator-local-name);
  if (prior-declarator)
    case
      ~ prior-declarator.full-definition =>
        prior-declarator.full-definition := struct;
      (referenced?(module, prior-declarator)) =>
        error(make(<idl-redefinition-after-use>, declarators: vector(struct, module, prior-declarator)));
    end case;
  end if;
end method;

define method check-before-add (module :: <ast-module>, struct :: <ast-forward-structure>)
  let prior-declarator
    = resolve-identifier(module, struct.declarator-local-name);
  if (prior-declarator & prior-declarator.declarator-scope == module)
    struct.full-definition := prior-declarator;
  else
    next-method();
  end if;
end method;

define method define-module (scope :: <scope>, identifier :: <ast-identifier>)
 => (module :: <ast-module>)
  let module = make(<ast-module>, local-name: identifier, pragmas: scepter-pragmas(get-scepter()));
  add-declarator(scope, module);
  module;
end method;

define method reopen-module (scope :: <scope>, identifier :: <ast-identifier>)
 => (module :: false-or(<ast-module>))
  resolve-identifier(scope, identifier);
end method;
