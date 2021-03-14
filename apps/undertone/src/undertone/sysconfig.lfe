;;;; The functions in this module process the classic Erlang property list
;;;; configuration data as maps. To be clear, all function outputs from this
;;;; module should be Erlang maps.
(defmodule undertone.sysconfig
  (export
   (backend 0)
   (backend-name 1)
   (backend-display 1)
   (backend-display-version 1)
   (backend-version 1)
   (banner-file 0)
   (banner 1)
   (config 1)
   (history 0)
   (priv-file 1)
   (prompt 0)
   (read-priv 1)
   (repl 0)
   (session 0)
   (version 1)
   (version+name 1)
   (version-arch 0)
   (version-system 0)
   (versions 1)
   (versions-deps 0)
   (versions-langs 0)
   (versions-rebar 0)))

(defun APPKEY () 'undertone)

(include-lib "lfe/include/clj.lfe")
(include-lib "logjam/include/logjam.hrl")

(defun backend ()
  (let* ((cfg (config 'backend))
         (name (mref cfg 'name)))
    (mset (maps:from_list (mref cfg name))
          'name
          name)))

(defun backend-name (bkend)
  (mref bkend 'name))

(defun backend-display (bkend)
  (mref bkend 'display-name))

(defun backend-display-version (bkend)
  (++ (backend-display bkend) " " (backend-version bkend)))

;; XXX delete this, and make versions something that that a backend's server state returns
(defun backend-version (bkend)
  (mref bkend 'version))

(defun banner-file ()
  (config 'banner))

;Docs: \e[1;34mhttps://cnbbooks.github.io/lfe-music-programming/current/ \e[0m
;File bug report: \e[1;34mhttps://github.com/lfex/undertone/issues/new \e[0m

(defun banner (bkend)
  "Colour sequence:
   - A series of blues for the mushroom and spores
   - The yellow 'welcome'
   - 3 clumps of grass
   - Top of the 'd'
   - 1 clump of grass
   - Top of the 't'
   - 3 clumps of grass
   - Top row of 'undertone'
  "
  (let ((data (binary_to_list (read-priv (banner-file))))
        (lcyan "\e[1;36m")
        (cyan "\e[36m")
        (lblue "\e[1;34m")
        (blue "\e[34m")
        (lyellow "\e[1;33m")
        (yellow "\e[33m")
        (magenta "\e[35m")
        (lgreen "\e[1;32m")
        (green "\e[32m")
        (white "\e[1;37m")
        (lgrey "\e[37m")
        (grey "\e[1;30m")
        (end "\e[0m"))
    ;; XXX using VERSION below (for latter replace) is a hack; should we
    ;;     instead return this whole thing as a format template, with ~s
    ;;     instead of VERSION?
    (io_lib:format data `(,lcyan ,end
                          ,blue  ,end
                          ,lcyan ,end

                          ,blue  ,end
                          ,lblue ,end
                          ,blue  ,end
                          ,lblue ,end

                          ,blue  ,end
                          ,lblue ,end
                          ,blue  ,end
                          ,lblue ,end

                          ,blue  ,end
                          ,cyan  ,end
                          ,blue  ,end
                          ,lblue ,end
                          ,blue  ,end

                          ,blue  ,end
                          ,cyan  ,end
                          ,blue  ,end
                          ,lblue ,end
                          ,blue  ,end

                          ,cyan  ,end
                          ,blue  ,end
                          ,lblue ,end
                          ,blue  ,end

                          ,cyan    ,end
                          ,blue    ,end
                          ,magenta ,end

                          ,cyan  ,end

                          ,green  ,end
                          ,lgreen ,end
                          ,green  ,end
                          ,lgreen ,end
                          ,cyan   ,end
                          ,green  ,end
                          ,lgreen ,end
                          ,green  ,end

                          ,white ,end

                          ,green  ,end
                          ,lgreen ,end
                          ,green  ,end

                          ,white ,end

                          ,green  ,end
                          ,lgreen ,end
                          ,green  ,end
                          ,lgreen ,end
                          ,green  ,end
                          ,lgreen ,end
                          ,green  ,end

                          ,white ,end
                          ,lgrey ,end
                          ,grey  ,end
                          ,(++ lyellow (version 'undertone) end)
                          ,(++ yellow "VERSION" end)
                          ,(++ "Docs: "
                               lblue
                               "https://cnbbooks.github.io/lfe-music-programming/"
                               end
                               "\n"
                               "Bug report: "
                               lblue
                               "https://github.com/lfex/undertone/issues/new"
                               end)
                          ,(prompt)))))

(defun config (key)
  (let ((`#(ok ,cfg) (application:get_env (APPKEY) key)))
    (try
      (maps:from_list cfg)
      (catch
        (`#(,_ ,_ ,_)
         (progn
           (log-debug "Couldn't convert value for ~p to map; using default value ..."
                     `(,key))
           cfg))))))

(defun history ()
  (config 'history))

(defun priv-file (priv-rel-path)
  (filename:join (code:priv_dir (APPKEY))
                 priv-rel-path))

(defun prompt ()
  ;; XXX This needs to be conditional, depending upon which REPL is running ...
  (config 'prompt))

(defun read-priv (priv-rel-path)
  (case (file:read_file (priv-file priv-rel-path))
    (`#(ok ,data) data)
    (other other)))

(defun repl ()
  (let* ((cfg (config 'repl))
         (xt (maps:from_list (mref cfg 'extempore)))
         (xt-banner-file (mref xt 'banner))
         (xt-prompt (mref xt 'prompt))
         (xt-banner-text (lists:flatten
                          (binary_to_list (read-priv xt-banner-file))))
         (ut (maps:from_list (mref cfg 'undertone)))
         (ut-banner-file (mref ut 'banner))
         (ut-prompt (mref ut 'prompt))
         (ut-banner-text (lists:flatten
                          (binary_to_list (read-priv ut-banner-file)))))
    (clj:-> cfg
            (mset 'extempore (mset xt
                                   'banner
                                   `#m(file ,xt-banner-file
                                       ;; XXX if we don't need to re-display the prompt
                                       ;; once this is a gen_server, we can remove the call
                                       ;; to format below; if we do need it, we'll replace
                                       ;; the empty string with the prompt
                                       text ,(io_lib:format
                                              xt-banner-text '("")))))
            (mset 'undertone (mset ut
                                   'banner
                                   `#m(file ,ut-banner-file
                                       ;; XXX see note above
                                       text ,(io_lib:format
                                              ut-banner-text '(""))))))))

(defun session ()
  (config 'session))

(defun version (app-name)
  (application:load app-name)
  (case (application:get_key app-name 'vsn)
    (`#(ok ,vsn) vsn)
    (default default)))

(defun version+name (app-name)
  `#(,app-name ,(version app-name)))

(defun version-arch ()
  `#(architecture ,(erlang:system_info 'system_architecture)))

(defun version-backend (bkend)
  `#(backend ,(backend-display-version bkend)))

(defun version-system ()
  (string:replace (erlang:system_info 'system_version)
                  "Erlang/OTP"
                  "LFE/OTP"))

(defun versions (bkend)
  (lists:append `((,(version-undertone)
                   ,(version-backend bkend))
                  ,(versions-deps)
                  ,(versions-langs)
                  ,(versions-rebar)
                  (,(version-arch)))))

(defun versions-deps ()
  `(,(version+name 'osc_lib)
    ,(version+name 'tcp-client)))


(defun versions-rebar ()
  `(,(version+name 'rebar)
    ,(version+name 'rebar3_lfe)))

(defun versions-langs ()
  `(,(version+name 'lfe)
    #(erlang ,(erlang:system_info 'otp_release))
    #(emulator ,(erlang:system_info 'version))
    #(driver ,(erlang:system_info 'driver_version))))

(defun version-undertone ()
  (version+name (APPKEY)))
