(when (eq system-type 'windows-nt)
  (setenv "PATH" (concat
		  ;; "c:/Windows/System32" ";"
                 "c:/tools/msys64/usr/bin" ";"
                 ;; Unix tools
                 ;; User binary files
                 (getenv "PATH")
		 ))
  (setq exec-path (append exec-path '("c:/tools/msys64/usr/bin")))
  )

(set-language-environment "UTF-8")

(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(tool-bar-mode -1)

;; Customize tabline
(global-display-line-numbers-mode t)
(global-tab-line-mode t)
(setq tab-line-separator ">")
;; tab color settings
(set-face-attribute 'tab-line nil ;; background behind tabs
      :background "gray40"
      :foreground "gray60" :distant-foreground "gray50"
      :height 1.0 :box nil)
(set-face-attribute 'tab-line-tab nil ;; active tab in another window
      :inherit 'tab-line
      :foreground "gray70" :background "gray90" :box nil)
(set-face-attribute 'tab-line-tab-current nil ;; active tab in current window
      :background "royalblue4" :foreground "white" :box nil)
(set-face-attribute 'tab-line-tab-inactive nil ;; inactive tab
      :background "gray60" :foreground "black" :box nil)
(set-face-attribute 'tab-line-highlight nil ;; mouseover
      :background "white" :foreground 'unspecified)


(tab-bar-mode t)

(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)

;; (add-to-list 'package-archives
;;             '("melpa" . "https://melpa.org/packages/"))
;; Evil mode

(package-initialize)
;; (package-refresh-contents)

;; This is only needed once, near the top of the file
(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  ;; (add-to-list 'load-path "~/.config/emacs")
  (require 'use-package))

;; Using Evil mode
;; (use-package evil
;;   :ensure t
;;   :bind (
;; 	 (:map evil-normal-state-map ("M-." . nil))
;; 	 (:map evil-insert-state-map ("M-." . nil))
;; 	)
;;   :config
;;   (require 'evil)
;;   (evil-mode 1))

(setq-default show-trailing-whitespace t)

;; show matching parentheses
(show-paren-mode t)
(set-face-attribute 'default nil :height 120)

(load-theme 'deeper-blue t)

(global-set-key (kbd "C-c C-c C-y") 'clipboard-yank)
(use-package rg
  :ensure t
)

(use-package projectile
  :ensure t
  :config
  ;; Config for projectile
  (require 'projectile)
  ;; Recommended keymap prefix on macOS
  ;; (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  ;; Recommended keymap prefix on Windows/Linux
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
)

(when (eq system-type 'windows-nt)
  (setq ispell-program-name "aspell.exe"))
(add-hook 'org-mode-hook (lambda () flyspell-mode 1))

;; Org-mode setting
(setq org-insert-mode-line-in-empty-file t)
(add-hook 'org-mode-hook
          (lambda () (progn (set-fill-column 72)
			    (flyspell-mode t)
			    (flyspell-buffer))))

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(use-package org-download
  :ensure t
  :init
  (add-hook 'dired-mode-hook 'org-download-enable)
)

;; Org-roam setting
;; (make-directory "~/workspace/Notes/org-roam")
(use-package org-roam
  :ensure t
  :init
  (setq org-roam-directory (file-truename "~/workspace/Notes/org-roam"))
  (org-roam-db-autosync-mode)
  (put 'narrow-to-region 'disabled nil)
)
;; Enable vertico
(use-package vertico
  :ensure t
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure t
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :ensure t
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(epa-file-enable)

;; keybinding for tabline
(global-set-key (kbd "M-,") 'tab-line-switch-to-prev-tab)
(global-set-key (kbd "M-.") 'tab-line-switch-to-next-tab)

;; (eval-after-load "evil-maps"
;;   (dolist (map '(evil-motion-state-map
;;                  evil-normal-state-map
;;                  evil-insert-state-map
;;                  evil-emacs-state-map))
;;     (define-key (eval map) "M-." nil)))
