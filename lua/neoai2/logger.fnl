; Logger module for NeoAI
; Source: original neoai.nvim

(fn debug [message]
  (vim.notify message vim.log.levels.DEBUG {:title :NeoAI}))

(fn info [message]
  (vim.notify message vim.log.levels.INFO {:title :NeoAI}))

(fn warning [message]
  (vim.notify message vim.log.levels.WARN {:title :NeoAI}))

(fn error [message]
  (vim.notify message vim.log.levels.ERROR {:title :NeoAI}))

(fn deprecation [what instead]
  (warning (.. what " is deprecated, use " instead)))

{: deprecation
 : debug
 : info
 : warning
 : error}
