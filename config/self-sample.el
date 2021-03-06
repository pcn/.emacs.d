;;;;
;; self-sample.el: specified yourself private configuration elisp file
;;                 and named it with self.el
;;;;






(def-self-prelogue
  (message "#self prelogue ...")

  (comment (setq debug-on-error t)))


(def-self-epilogue
  (message "#self epilogue ...")
  
  (safe-fn-when org-agenda
    (global-set-key (kbd "C-c a") 'org-agenda))
  (safe-fn-when org-capture
    (global-set-key (kbd "C-c c") 'org-capture))
  
  (comment
   (version-supported-if
       <= 25.2
       (setq source-directory "/opt/open/emacs-25/")
     (setq source-directory "/opt/open/emacs-22/"))))

;; define env-spec
(def-self-env-spec
  :theme (list :name 'atom-one-dark
               :path (emacs-home* "theme/")
               :allowed t)
  :font (list :name "Monaco-13"
              :allowed t)
  :cjk-font (list :name "Microsoft Yahei"
                  :size 13
                  :allowed nil)
  :desktop (list :files-not-to-save "\.el\.gz\\|~$"
                 :buffers-not-to-save "^TAGS\\|\\.log"
                 :modes-not-to-save '(dired-mode)
                 :allowed t)
  (comment
   :socks (list :port 11032
                :server "127.0.0.1"
                :version 5
                :allowed t)))


;; define package-spec
(def-self-package-spec
  (list
   :cond (lambda ()
           (bin-exists-p "latex"))
   :packages '(auctex cdlatex)
   :setup (lambda () (message "#setup: Hi, LaTex")))
  (list
   :cond (lambda ()
           (and (version-supported-p '<= 24.4)
                (platform-supported-if
                    darwin
                    (zerop (shell-command
                            "/usr/libexec/java_home -V &>/dev/null"))
                  (bin-exists-p "java"))))
   :packages '(cider
               clojure-mode
               clojure-mode-extra-font-locking)
   :setup `(,(emacs-home* "config/setup-clojure.el")))
  (list
   :cond (lambda ()
           (and (version-supported-p '<= 24.4)
                (bin-exists-p "docker")))
   :packages '(dockerfile-mode
               docker-tramp))
  (list
   :cond (lambda ()
           (bin-exists-p "erlc"))
   :packages '(erlang))
  (list
   :cond (lambda ()
           (and (bin-exists-p "erlc")
                (bin-exists-p "lfe")))
   :packages '(lfe-mode)
   :setup `(,(emacs-home* "config/setup-lfe.el")))
  (list
   :cond (lambda ()
           (and (platform-supported-unless darwin t)
                (version-supported-p '<= 25.1)))
   :packages '(ereader))
  (list
   :cond (lambda ()
           (and (version-supported-p '<= 24.4)
                (bin-exists-p "git")))
   :packages '(magit)
   :setup `(,(emacs-home* "config/setup-magit.el")))
  (list
   :cond (lambda ()
           (and (version-supported-p '<= 23.2)
                (bin-exists-p "racket")))
   :packages '(geiser))
  (list
   :cond (lambda ()
           (or (bin-exists-p "sbcl")))
   :packages '(slime)
   :setup `(,(emacs-home* "config/setup-slime.el")))
  (list
   :cond (lambda () t)
   :packages '(sx)
   :setup (lambda () (message "# [sx], may be we don't need it."))))
