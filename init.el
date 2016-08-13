(defmacro comment (&rest body)
  "Ignores body, yields nil."
  nil)

(defmacro time (expr)
  "Evaluates expr and prints the time it took. Returns the value of expr."
  `(let ((start (current-time))
         (return ,expr))
     (print (format "Elapsed %f secs."
                    (float-time
                     (time-subtract (current-time) start))))
     return))

(defconst loading-start-time
  (current-time) "The start time at loading init.el")

(defun compile-and-load-elisp-files (files subdir)
  "Compile and load the elisp files under the subdir."
  (let ((d (concat "~/.emacs.d/" subdir)))
    (dolist (f files)
      (let* ((from (concat d f))
             (to (replace-regexp-in-string
                  "\.el$" "\.elc" from)))
        (when (or (not (file-exists-p to))
                  (file-newer-than-file-p from to))
          (setq compiled (byte-compile-file from)))
        (load to)))))

(defmacro package-supported-p (&rest body)
  "Run body code if the Emacs supports package."
  `(when (>= emacs-major-version 24)
     (progn ,@body)))

(defmacro plateform-supported-p (os &rest body)
  "Run body code if the Emacs on specified OS plateform."
  `(when (eq system-type ,os)
     (progn ,@body)))

(defmacro version-supported-p (c v &rest body)
  "Run body code if the Emacs on specified version."
  `(when (,c ,v (string-to-number emacs-version))
     ,@body))

(defmacro bin-exists-p (b)
  "Returns true if b exists in env."
  `(zerop (shell-command (concat "type -p " ,b " 2>&1 >/dev/null"))))

(defmacro safe-call (fn &rest args)
  `(when (fboundp (quote ,fn)) (apply (quote ,fn) (quote ,args))))

(defconst has-java (bin-exists-p "java"))
(defconst has-erlang (bin-exists-p "erl"))

;; First to load UI part
(compile-and-load-elisp-files '("ui.el") "config/")

;; Start loading ...
(package-supported-p
 ;; define package repositories
 (setq package-archives 
       '(("gnu" . "http://elpa.gnu.org/packages/")
         ("melpa-stable" . "http://stable.melpa.org/packages/")))
 ;; guarantee all packages are installed on start
 (defconst installed-packages
   (let* ((basic '(aggressive-indent
                   bing-dict
                   exec-path-from-shell
                   ido-ubiquitous
                   markdown-mode
                   paredit
                   rainbow-delimiters
                   smex
                   tagedit))
	  (java '(cider clojure-mode clojure-mode-extra-font-locking))
	  (erlang '(erlang lfe-mode))
	  (docker '(docker dockerfile-mode)))
     (append basic
             (version-supported-p <= 24.4 docker)
             (version-supported-p <= 24.4 '(magit))
             (when has-java java)
	     (when has-erlang erlang))))
   
 (require 'package)
 (package-initialize)

 (let ((not-installed-packages
        (delete t (mapcar #'(lambda (p) (if (package-installed-p p) t p))
                          installed-packages))))
   (when not-installed-packages
     (package-refresh-contents)
     (message "#Installing the missing %d packages: %s"
              (length not-installed-packages)
              not-installed-packages)
     (mapcar #'(lambda (i) (package-install i))
             not-installed-packages)))

  (compile-and-load-elisp-files
   ;; compile and load basic elisp files
   (let* ((basic '("misc.el"
                   "navigation.el"
                   "setup-python.el"
                   "setup-shell.el"))
          (clojure (when has-java '("setup-clojure.el")))
          (lfe (when has-erlang '("setup-lfe.el"))))
     (append basic clojure lfe)) "config/"))
  
 ;; ^ end of support-package-p


(compile-and-load-elisp-files
 ;; compile and load non-package-required elisp files
 '("editing.el"
   "lisp-editing.el"
   "setup-debugger.el") "config/")

(compile-and-load-elisp-files
 ;; compile and load private non-package-required elisp files
 '("financial.el"
   "utils.el") "private/n/")

;; After loaded ...
(let ((elapsed
       (float-time
        (time-subtract (current-time) loading-start-time))))
  (message "#Loading init.el ... done (%.3fs)" elapsed))

(put 'upcase-region 'disabled nil)

