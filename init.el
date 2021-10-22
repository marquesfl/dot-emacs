;;; -*- lexical-binding: t -*-
(set-language-environment "UTF-8")

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(let* ((package--builtins nil)
       (packages
        '(auto-compile         ; automatically compile Emacs Lisp libraries
          cider                ; Clojure Interactive Development Environment
          clj-refactor         ; Commands for refactoring Clojure code
          company              ; Modular text completion framework
          counsel              ; Various completion functions using Ivy
          counsel-projectile   ; Ivy integration for Projectile
          haskell-mode         ; A Haskell editing mode
          jedi                 ; Python auto-completion for Emacs
          js2-mode             ; Improved JavaScript editing mode
          lsp-mode             ; LSP mode
          lsp-java             ; Java support for lsp-mode
          magit                ; control Git from Emacs
          markdown-mode        ; Emacs Major mode for Markdown-formatted files
          org                  ; Outline-based notes management and organizer
          org-bullets          ; Show bullets in org-mode as UTF-8 characters
          paredit              ; minor mode for editing parentheses
          projectile           ; Manage and navigate projects in Emacs easily
          slime)))             ; Superior Lisp Interaction Mode for Emacs
  (when (memq window-system '(mac ns))
    (push 'exec-path-from-shell packages)
    (push 'reveal-in-osx-finder packages))
  (let ((packages (seq-remove 'package-installed-p packages)))
    (print packages)
    (when packages
      ;; Install uninstalled packages
      (package-refresh-contents)
      (mapc 'package-install packages))))

(defun tangle-init ()
  "If the current buffer is 'init.org' the code-blocks are tangled, and the tangled file is compiled."
  (when (equal (buffer-file-name)
               (expand-file-name (concat user-emacs-directory "init.org")))
    ;; Avoid running hooks when tangling.
    (let ((prog-mode-hook nil))
      (org-babel-tangle)
      (byte-compile-file (concat user-emacs-directory "init.el")))))
(add-hook 'after-save-hook 'tangle-init)

(fset 'yes-or-no-p 'y-or-n-p)

(defvar emacs-autosave-directory
  (concat user-emacs-directory "autosaves/")
  "This variable dictates where to put auto saves. It is set to a directory called autosaves located wherever your .emacs.d/ is located.")

;; Sets all files to be backed up and auto saved in a single directory.
(setq backup-directory-alist
      `((".*" . ,emacs-autosave-directory))
      auto-save-file-name-transforms
      `((".*" ,emacs-autosave-directory t)))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

(dolist (mode '(tool-bar-mode                ; No toolbars, more room for text
                scroll-bar-mode              ; No scroll bars either
                blink-cursor-mode))          ; The blinking cursor gets old
  (funcall mode 0))

;; Set up the visible bell
(setq visible-bell t)

;; Set fullscreen
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Set default
(setq-default indent-tabs-mode nil)
(set-face-attribute 'default nil :height 160)

(dolist (mode
         '(abbrev-mode                  ; E.g. sopl -> System.out.println
           column-number-mode           ; Show column number in mode line
           delete-selection-mode        ; Replace selected text
           dirtrack-mode                ; directory tracking in *shell*
           global-company-mode          ; Auto-completion everywhere
           counsel-projectile-mode      ; Manage and navigate projects
           recentf-mode                 ; Recently opened files
           show-paren-mode))            ; Highlight matching parentheses
  (funcall mode 1))

(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq ivy-wrap t
      ivy-height 25
      ivy-use-virtual-buffers t
      ivy-count-format "(%d/%d) "
      ivy-on-del-error-function 'ignore)
(ivy-mode 1)

(setq company-idle-delay 0
      company-echo-delay 0
      company-dabbrev-downcase nil
      company-minimum-prefix-length 2
      company-selection-wrap-around t
      company-transformers '(company-sort-by-occurrence
                             company-sort-by-backend-importance))

(setq org-agenda-files '("~/Documents/Sistema, Templo/Tarefas.org" 
                         "~/Documents/Sistema, Templo/Agenda.org"
                         "~/Documents/Escriba.org"))

(with-eval-after-load 'lsp-mode
  (define-key lsp-mode-map (kbd "C-c f") lsp-command-map)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

(dolist (mode '(cider-repl-mode
                clojure-mode
                slime-repl-mode
                lisp-mode
                emacs-lisp-mode
                lisp-interaction-mode))
  ;; add paredit-mode to all mode-hooks
  (add-hook (intern (concat (symbol-name mode) "-hook")) 'paredit-mode))

(setq inferior-lisp-program "sbcl")

(setq python-shell-interpreter "python3")
(add-hook 'python-mode-hook
          (lambda () (setq forward-sexp-function nil)))

(defun c-setup ()
  (local-set-key (kbd "C-c C-c") 'compile))

(add-hook 'c-mode-hook 'c-setup)

(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

(setq haskell-process-args-ghci
      '("-ferror-spans" "-fshow-loaded-modules"))

(setq haskell-process-args-cabal-repl
      '("--ghc-options=-ferror-spans -fshow-loaded-modules"))

(setq haskell-process-args-stack-ghci
      '("--ghci-options=-ferror-spans -fshow-loaded-modules"
        "--no-build" "--no-load"))

(setq haskell-process-args-cabal-new-repl
      '("--ghc-options=-ferror-spans -fshow-loaded-modules"))

(defvar custom-bindings-map (make-keymap)
  "A keymap for custom bindings.")

(define-key custom-bindings-map (kbd "C-c e")  'mc/edit-lines)
(define-key custom-bindings-map (kbd "C-c a")  'mc/mark-all-like-this)
(define-key custom-bindings-map (kbd "C-c n")  'mc/mark-next-like-this)

(define-key custom-bindings-map (kbd "C-c m") 'magit-status)

(global-set-key (kbd "C-c i")   'swiper-isearch)
(global-set-key (kbd "M-x")     'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-y")     'counsel-yank-pop)
(global-set-key (kbd "C-x b")   'ivy-switch-buffer)

(define-key company-active-map (kbd "C-d")   'company-show-doc-buffer)
(define-key company-active-map (kbd "C-n")   'company-select-next)
(define-key company-active-map (kbd "C-p")   'company-select-previous)
(define-key company-active-map (kbd "<tab>") 'company-complete)

(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

(global-set-key (kbd "C-ç c") 'copy-region-as-kill)
(global-set-key (kbd "C-ç v") 'yank)
(global-set-key (kbd "C-ç x") 'kill-region)
(global-set-key (kbd "C-ç p") 'print-region)
(global-set-key (kbd "C-ç <tab>") 'switch-to-next-buffer)

(define-minor-mode custom-bindings-mode
  "A mode that activates custom-bindings."
  t nil custom-bindings-map)

(global-set-key (kbd "C-ç a") 'org-agenda)
