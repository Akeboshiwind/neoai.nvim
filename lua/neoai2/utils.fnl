; TODO: Replace with :nfnl.core and vim utils

(fn concat [a ...]
  (var out [(unpack a)])
  (each [_ tbl (ipairs [...])]
    (each [_ v (ipairs tbl)]
      (table.insert out v)))
  out)

(fn clone [tbl]
  (let [ret {}]

    ; Keyed entries
    (each [k v (pairs tbl)]
      (if (= (type v) :table)
        (tset ret k (clone v))
        (tset ret k v)))

    ; Indexed entries
    (each [k v (ipairs tbl)]
      (if (= (type v) :table)
        (tset ret k (clone v))
        (tset ret k v)))

    ret))
  
; TODO: replace with vim.split
; Translated using antifennel
(fn split [input delimiter]
  (let [result {}]
    (var start 1)
    (var (split-start split-end) nil)
    (while true
      (set (split-start split-end) (string.find input delimiter start true))
      (when (not split-start)
        (table.insert result (string.sub input start))
        (lua :break))
      (table.insert result (string.sub input start (- split-start 1)))
      (set start (+ split-end 1)))
    result))

(fn lines [str]
  (split str "\n"))

(fn shell-error [str]
  (not= 0 vim.v.shell_error))

(fn buf-empty? [bufnr]
  ; NOTE: `nvim_buf_get_lines` will return an empty string for the
  ;       first line of an empty buffer.
  ;       Instead we get the first two lines, if only one line is
  ;       returned **and** it is empty, then we know the buffer is
  ;       empty.
  (let [start-of-buf (vim.api.nvim_buf_get_lines bufnr 0 2 false)]
    (and (= (length start-of-buf) 1)
         (= (. start-of-buf 1) ""))))

; Hacked together from:
; https://github.com/nvim-telescope/telescope.nvim/pull/2333/files#diff-28bcf3ba7abec8e505297db6ed632962cbbec357328d4e0f6c6eca4fac1c0c48R170
(fn selection []
  (let [mode (vim.fn.mode)]
    (when (or (= mode :v) (= mode :V))
      (let [saved-reg (vim.fn.getreg :v)
            _ (vim.cmd "noautocmd sil norm \"vy")
            selection (vim.fn.getreg :v)]
        (vim.fn.setreg :v saved-reg)
        selection))))

(local json {})

(fn json.store [obj path]
  (let [(ok file-contents) (pcall vim.json.encode obj)]
    (if (not ok)
       (values false (.. "Failed to encode json: " file-contents))
       (let [(ok err) (pcall vim.fn.writefile [file-contents] path)]
         (if (not ok)
            (values false err)
            true)))))

(fn json.load [path]
  (let [(ok file-contents) (pcall vim.fn.readfile path)]
    (if (not ok)
       (values nil file-contents)
       (let [(ok obj) (pcall vim.json.decode
                             (table.concat file-contents "\n"))]
         (if (not ok)
            (values nil (.. "Failed to decode json: " obj))
            obj)))))

{: concat
 : clone
 : split
 : lines
 :shell_error shell-error
 :is_buf_empty buf-empty?
 : selection
 : json}
