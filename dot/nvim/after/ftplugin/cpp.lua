-- Disable rainbow delimiters initially. Can re-enable with keymap. Rationale is
--  - TreeSitter based syntax highlighting colors operator() and operator[]
--    calls which would not be noticeable when all braces are colored
--  - Often braces are simple enough that the coloring would be more distracting
--    than helpful.
-- The plugin has no way to specify disabled-by-default. Blacklisting or 'nil'
-- strategy would make it impossible to activate later.
require('rainbow-delimiters').disable(0)
