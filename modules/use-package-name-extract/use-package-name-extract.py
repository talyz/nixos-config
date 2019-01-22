#!/usr/bin/env python3

import re, sys


def find_all_usepackage_sexps(sexp_list, text):
    until_next = r'[^()";]*' # Match until next common relevant token.
    rest = r'((?:.|\n)*)' # Match rest of file.

    # Match any line beginning with '(use-package', then match until
    # next relevant token (open paren, close paren, quote, etc).
    match = re.search(f'''(
                              ^\s*\\(use-package
                              {until_next}
                          )'''
                      + rest,
                      text, re.MULTILINE | re.VERBOSE)

    if match:
        # current_sexp holds everything matched in the sexp so far,
        # remaining holds the rest of the file.
        (current_sexp, remaining) = match.groups()

        # Count the parens - when they're equal in numbers, the sexp
        # is over.
        open_parens = 1
        close_parens = 0
        while open_parens > close_parens:
            # Match comment (from semicolon until newline) and simply
            # discard it - we don't want to count parens in comments
            # or act on a commented-out ':ensure'. Then match until
            # next relevant token and add to the sexp.
            match = re.search(r'^;+.*\n' + f'({until_next})' + rest, remaining)
            if match:
                current_sexp += match.group(1)
                remaining = match.group(2)
                continue

            # Match strings and add them to the sexp, but don't count
            # parens inside. This can handle escaped quotes inside the
            # string, but not an escaped backslash right before the
            # closing quote.
            match = re.search(f'''(
                                      ^"                 # start quote
                                      (?:[^"]|\\\\")*    # ..everything except a quote
                                                         # and escaped quote..
                                      (?<!\\\\)"         # ..end quote, explicitly not
                                                         # preceded by a backslash (escaped)
                                      {until_next}
                                  )'''
                              + rest,
                              remaining,
                              re.VERBOSE)
            if match:
                current_sexp += match.group(1)
                remaining = match.group(2)
                continue

            # Match either an opening paren or closing paren and
            # increment the corresponding counter.
            match = re.search(f'(^\\({until_next})' + rest, remaining)
            if match:
                open_parens += 1
            else:
                match = re.search(f'(^\\){until_next})' + rest, remaining)
                if match:
                    close_parens += 1
                else:
                    print(current_sexp)
                    raise EOFError
            current_sexp += match.group(1)
            remaining = match.group(2)
        return find_all_usepackage_sexps(sexp_list + [current_sexp], remaining)
    else:
        return sexp_list


with open(sys.argv[1]) as emacs_conf:
    for i in find_all_usepackage_sexps([], emacs_conf.read()):
        # Match only packages with an :ensure keyword, to approximate
        # real use-package behaviour.
        match = re.search(r''':ensure\s+
                              (
                                  (?!:)                  # Don't match the next keyword.
                                  (?:[^;()\s\\]|\\.)*    # Anything except semicolon, parens,
                                                         # whitespace or backslash, unless
                                                         # prefixed with a backslash (escaped).
                              )''',
                          i,
                          re.VERBOSE | re.MULTILINE)
        if match:
            ensure = match.group(1)
            # If nil follows :ensure, the package should not be
            # installed.
            if ensure == "nil":
                continue
            # If anything but space or 't' follows :ensure, it should
            # be used in place of the name given to use-package when
            # looking for packages to install.
            if ensure not in ("", "t"):
                print(ensure)
            else:
                match = re.search(r'''^\s*\(use-package\s+
                                      (
                                          (?:[^;()\s\\]|\\.)*
                                      )''',
                                  i,
                                  re.VERBOSE | re.MULTILINE)
                if match:
                    print(match.group(1))
