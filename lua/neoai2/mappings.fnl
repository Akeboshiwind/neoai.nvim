; "Stolen" from dressing.nvim
; TODO: Properly attribute this & figure out licensing
(local {: first : table? : string?} (require :nfnl.core))

(fn create-plug-maps [bufnr plug-bindings]
  (each [_ binding (ipairs plug-bindings)]
    (vim.keymap.set "" binding.plug binding.rhs
      {:buffer bufnr
       :desc binding.desc
       :nowait true})))

(fn create-maps-to-plug [bufnr mode bindings prefix]
  (each [lhs rhs (pairs bindings)]
    (when rhs
      (let [opts (collect [k v (pairs (if (table? rhs) rhs {}))
                           &into {:buffer bufnr 
                                  :nowait true
                                  :remap true}]
                   (when (= (type k) :string)
                     (values k v)))
            rhs (if (and (table? rhs) (first rhs))
                  (first rhs)
                  rhs)
            ; Prefix with <Plug> unless this is a <Cmd> or :Cmd mapping
            rhs (if (string? rhs)
                  (if (not (rhs:match "[<:]"))
                    (.. "<Plug>" prefix rhs "<CR>")
                    (.. rhs "<CR>"))
                  rhs)
            rhs (if (and (string? rhs) (= mode :i))
                  (.. "<C-o>" rhs)
                  rhs)]
        (vim.keymap.set mode lhs rhs opts)))))

{:create_plug_maps create-plug-maps
 :create_maps_to_plug create-maps-to-plug}
