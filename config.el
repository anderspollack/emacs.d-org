(server-start)

(defun my-minibuffer-setup-hook ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun my-minibuffer-exit-hook ()
  (setq gc-cons-threshold 800000))

(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)

(if (not (window-system))
    (global-set-key (kbd "<mouse-5>") 'scroll-up-line))
(if (not (window-system))
    (global-set-key (kbd "<mouse-4>") 'scroll-down-line))

(add-hook 'term-mode-hook
          (lambda ()
            (define-key term-raw-map (kbd "C-y") 'term-paste)))

(setq initial-frame-alist
      (append (list '(top . 50)
                    '(left . 50))))

(setq default-frame-alist
      (append (list '(width  . 140)
                    '(height . 56)
                    '(vertical-scroll-bars . nil)
                    '(internal-border-width . 17))))
(set-frame-parameter
 (selected-frame) 'internal-border-width 17)

(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

(set-mouse-color "#000000")

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)

(add-hook 'text-mode-hook
          (lambda ()
            (variable-pitch-mode 1)))

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(use-package magit
  :ensure t
  :config
  (global-set-key (kbd "C-x g") 'magit-status))

(use-package evil
  :ensure t
  :init
  (setq evil-search-module 'evil-search)
  (setq evil-ex-complete-emacs-commands nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-u-delete t)
  (setq evil-want-keybinding nil)
  (setq evil-want-fine-undo t)
  (setq evil-want-C-u-delete t)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  (evil-set-initial-state 'shell-mode 'insert)
  (evil-set-initial-state 'eshell-mode 'insert)
  (evil-set-initial-state 'term-mode 'insert)
  ;; set magit commit messages to open in insert state https://emacs.stackexchange.com/questions/14008/default-magit-commit-state-in-evil
  (add-hook 'with-editor-mode-hook 'evil-insert-state)
  ;; set C-y to paste text in insert mode -- uses evil-paste-before + right-char instead of yank to make pasting in the terminal work
  (define-key evil-insert-state-map (kbd "C-y") (lambda ()
                                                  (interactive)
                                                  (evil-paste-before 1)
                                                  (right-char 1)))
  ;; set C-d to delete text in insert mode, like emacs + readline
  (define-key evil-insert-state-map (kbd "C-d") 'delete-char)
  ;; remap all evil movement functions to use visual lines instead of actual lines
  (define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
  (define-key evil-motion-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
  ;; Make horizontal movement cross lines
  (setq-default evil-cross-lines t)
  ;; set RETURN to open links in org-mode
  (add-hook 'org-mode-hook (lambda ()
                             (define-key evil-normal-state-map (kbd "RET") 'org-open-at-point)))
  )

(use-package evil-leader
  :after evil
  :ensure t
  :config
  (global-evil-leader-mode t)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "f" 'find-file
    "b" 'switch-to-buffer
    "d" 'dired
    "s" 'save-buffer
    "1" 'delete-other-windows
    "2" 'evil-window-split
    "3" 'evil-window-vsplit
    "0" (lambda ()
          (interactive)
          (delete-window))
    "=" 'balance-windows
    "o" 'other-window
    "h" 'windmove-left
    "j" 'windmove-down
    "k" 'windmove-up
    "l" 'windmove-right
    "m" 'toggle-frame-fullscreen
    "n" 'make-frame
    "w" 'delete-frame
    "r" (lambda ()
          "if the current buffer is web-mode, run web-mode-reload, otherwise run font-lock-fontify-buffer"
          (interactive)
          (if (string= (symbol-value 'major-mode) "web-mode")
              (web-mode-reload)
            (font-lock-fontify-buffer)))
    "e" 'eshell
    "t" 'ansi-term
    "g" 'magit-status
    "u" 'undo-tree-visualize
    ;; make SPC-SPC enlarge the current window in both dimensions. NOTE: annoying on a butterfly keyboard macbook, great otherwise
    ;; "SPC" 'maximize-window
    ;; make SPC-SPC just C-g
    "SPC" 'keyboard-quit
    "%" 'query-replace
    "!" 'shell-command
    "x" 'execute-extended-command
    "<left>" 'winner-undo
    "<right>" 'winner-redo
    )
  ;; set SPC-' to toggle editing of org-src blocks
  (evil-leader/set-key "'" 'org-edit-src-exit)
  (evil-leader/set-key-for-mode 'org-mode "'" 'org-edit-special)

  ;; set SPC-SPC to move forward in info mode
  (evil-leader/set-key-for-mode 'info-mode "SPC" 'Info-scroll-up)
  )

(use-package evil-surround
  :after evil
  :ensure t
  :config
  (global-evil-surround-mode t))

(use-package evil-magit
  :after evil
  :ensure t
  :config
  (global-evil-surround-mode t))

(use-package evil-org
  :after evil
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
            (lambda ()
              (evil-org-set-key-theme)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package company
  :ensure t)

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.js?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.php?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tag?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.liquid?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.json?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.vue?\\'" . web-mode))
  (setq web-mode-engines-alist
        '(
          ("riot" . "\\.tag\\'")
          ("liquid" . "\\.liquid\\'")
          ))

  (setq web-mode-content-types-alist
        '(
          ("json" . "\\.json\\'")
          ("jsx" . "\\.jsx\\'")
          ("jsx" . "/Users/Anders/Sites/portfolio/src/.*\\.js\\'")
          ("jsx" . "/Users/Anders/Sites/talk-about/src/.*\\.js\\'")
          ("jsx" . "/Users/Anders/Sites/music-directory/client/src/.*\\.tsx\\'")
          ("css" . "/Users/Anders/Sites/super-deluxe-2018/.*\\.scss.liquid\\'")
          ("liquid" . "/Users/Anders/Sites/donpollack/donpollack/.*\\.liquid\\'")
          ("jsx" . "/Users/Anders/Code/coding-circle/charades/client/src/.*\\.jsx\\'")
          ))

  ;; set indentation level to 2/4 for html/markup
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-style-padding 0)
  (setq web-mode-script-padding 0)

  ;; enable jsdoc-style comments
  (setq web-mode-enable-comment-annotation t)

  ;; disable electric pair mode in web mode for liquid files
  (add-hook 'web-mode-hook
            (lambda () (if (equal (file-name-extension(buffer-file-name))
                                  "liquid")
                           (electric-pair-local-mode -1)))))

(use-package emmet-mode
  :ensure t
  :config
  ;; Auto-start on any markup modes
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'html-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook  'emmet-mode)
  (add-hook 'markdown-mode-hook  'emmet-mode)
  ;; enable emmet mode whenever web-mode is active
  (add-hook 'web-mode-hook 'emmet-mode))

(use-package lsp-mode
  :ensure t
  :init
  ;; set prefix for all lsp commands as C-c l
  (setq lsp-keymap-prefix "C-c l")
  :hook
  ;; deferred startup for lsp until a web-mode buffer is opened
  (web-mode . lsp-deferred)
  ;; enable which-key integration
  (lsp-mode . lsp-enable-which-key-integration)
  :commands
  (lsp lsp-deferred))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(use-package company-lsp
  :ensure t
  :commands company-lsp)

(use-package prettier-js
  :ensure t
  :config
  (add-hook 'web-mode-hook 'prettier-js-mode))

(use-package which-key
  :ensure t
  :config
  (setq which-key-mode t))

(use-package yaml-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode)))

(setq load-path (cons "~/.emacs.d/tidal/" load-path))
(use-package haskell-mode
  :ensure t)
(use-package tidal
  :ensure t
  :config
  ;; (setq tidal-interpreter "/usr/local/bin/ghci")
  )

(use-package powerline
  :ensure t
  :config
  (powerline-center-evil-theme))

(global-set-key (kbd "M-J")
                (lambda ()
                  (interactive)
                  (evil-window-increase-height 1)
                  (evil-window-increase-width 3)
                  ))

(global-set-key (kbd "M-K")
                (lambda ()
                  (interactive)
                  (evil-window-decrease-height 1)
                  (evil-window-decrease-width 3)
                  ))

(add-hook 'dired-mode-hook
          (lambda ()
            (dired-hide-details-mode)
            (dired-sort-toggle-or-edit)))

(when (string= system-type "darwin")
  (setq dired-use-ls-dired nil))

(setq default-directory "~/")

(add-hook
 'eshell-mode-hook
 (lambda ()
   (setq pcomplete-cycle-completions nil)))

(defalias 'yes-or-no-p 'y-or-n-p)

(global-set-key (kbd "M-i") 'imenu)

(setq backup-directory-alist '(("." . "~/.emacs.d/backup")))

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
