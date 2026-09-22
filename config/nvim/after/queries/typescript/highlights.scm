; extends

; TypeScript's language service gives Cursor these semantic classifications,
; but ts_ls does not expose semantic tokens over LSP.
(import_specifier
  name: (identifier) @function
  (#match? @function "^[a-z]"))

((identifier) @variable.default_library
  (#eq? @variable.default_library "process"))
