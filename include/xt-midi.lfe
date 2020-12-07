(defmacro midi-init args `(xt.midi:init ,@args))
(defmacro midi-devices args `(xt.midi:list-devices ,@args))
(defmacro set-midi-out! args `(xt.midi:set-out-streanm! ,@args))

;; This function is for display purpses when used in the REPL
;; and need to be the last function in the include file.
(defun |-- loaded include: xt-midi --| ()
  'ok)