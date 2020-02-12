;; prevent org code execution confirmation, enable syntax hightlighting and native tab behavior in source code blocks

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq org-confirm-babel-evaluate nil
      org-src-fontify-natively t
      org-src-tab-acts-natively t)

;; setup org-babel to execute code in these languages:
(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (C . t)
   (css . t)
   (emacs-lisp . t)
   (js . t)
   ;; (lua . t)
   ;; (processing . t)
   ;; (ruby . t)
   ;; (shell . t)
   ;; (sh . t)
   ))

(require 'org)

;; set gc-cons-threshold to maximum while loading config for fast startup
(let ((gc-cons-threshold most-positive-fixnum))
  ;; load org config file
  (org-babel-load-file
   (expand-file-name "config.org"
                     user-emacs-directory))
  )

;; this is where emacs enables commands that warn before executing
(put 'set-goal-column 'disabled nil)
(put 'narrow-to-region 'disabled nil)
