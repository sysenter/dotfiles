;; Place backups in a non-evident directory.

(setq backup-directory-alist (quote ((".*" . "~/.emacs.d/backups"))))

;; Includes ...

(add-to-list 'load-path "~/elisp/")
(add-to-list 'load-path "~/elisp/ruby-mode")
(add-to-list 'load-path "~/elisp/color-theme-6.6.0")

(menu-bar-mode 1)

(require 'zenburn)
(require 'multi-term)

(zenburn)

(require 'smart-compile)

(set-background-color "black")
(set-foreground-color "white")

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))


;; Highlight minor mode.

(require 'highlight-parentheses)

(add-hook 'emacs-lisp-mode-hook
          '(lambda ()
             (highlight-parentheses-mode)
             (setq autopair-handle-action-fns
                   (list 'autopair-default-handle-action
                         '(lambda (action pair pos-before)
                            (hl-paren-color-update))))))

;; And show-parens.

(show-paren-mode 1)                                                                                                                                                                   

(require 'paren)

(set-face-background 'show-paren-match-face (face-background 'default))
(set-face-foreground 'show-paren-match-face "#def")
(set-face-attribute 'show-paren-match-face nil :weight 'extra-bold)

(defun lispy-parens ()
  "Setup parens display for lisp modes"
  (setq show-paren-delay 0)
  (setq show-paren-style 'parenthesis)
  (make-variable-buffer-local 'show-paren-mode)
  (show-paren-mode 1)
  (set-face-background 'show-paren-match-face (face-background 'default))
  (if (boundp 'font-lock-comment-face)
      (set-face-foreground 'show-paren-match-face
                           (face-foreground 'font-lock-comment-face))
    (set-face-foreground 'show-paren-match-face
                         (face-foreground 'default)))
  (set-face-attribute 'show-paren-match-face nil :weight 'extra-bold))

;; Ruby-mode.

(autoload 'ruby-mode "ruby-mode" "Major mode for ruby files" t)
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))

;; C-indentation/appearance related stuff.

(global-font-lock-mode t)
(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (c-set-style "K&R")
  (global-set-key "\C-u" 'c-electric-delete)
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 2))

(setq kill-whole-line t)
(setq c-hungry-delete-key t)

(setq c-auto-newline 0)

(add-hook 'c-mode-common-hook
          '(lambda ()
             (turn-on-auto-fill)
             (setq fill-column 75)
             (setq comment-column 60)
             (modify-syntax-entry ?_ "w") ;; '_' is now a delimiter.
             (c-set-style "ellemtel") ;; indentation style
             (local-set-key [(control tab)] ;; move to next temporary mark
                            'tempo-forward-mark)
             ))

;; }}}

(transient-mark-mode t)
(autoload 'javascript-mode "javascript" nil t)

;; General look and feel.

(setq default-frame-alist
      '((top . 80) (left . 64)
	(width . 75) (height . 40)
	(cursor-type . box)))

(add-hook 'octave-mode-hook
	  (lambda()
	    (setq octave-auto-indent 1)
	    (setq octave-blink-matching-block 1)
	    (setq octave-block-offset 8)
	    (setq octave-send-line-auto-forward 0)
	    (abbrev-mode 1)
	    (auto-fill-mode 1)
	    (if (eq window-system 'x)
		(font-lock-mode 1))))

;; Codepad.

(add-to-list 'load-path "~/elisp/emacs-codepad")
(autoload 'codepad-paste-region "codepad" "Paste region to codepad.org." t)
(autoload 'codepad-paste-buffer "codepad" "Paste buffer to codepad.org." t)
(autoload 'codepad-fetch-code "codepad" "Fetch code from codepad.org." t)

;; Autocomplete Stuff.

(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/elisp/auto-complete-1.3//ac-dict")
(ac-config-default)

;; dirty fix for having AC everywhere, can get annoying.

(define-globalized-minor-mode real-global-auto-complete-mode
  auto-complete-mode (lambda ()
		       (if (not (minibufferp (current-buffer)))
			   (auto-complete-mode 1))
		       ))
(real-global-auto-complete-mode t)

;; Slime mode

(add-to-list 'load-path "~/elisp/slime/")
(setq inferior-lisp-program "/usr/bin/sbcl")
(require 'slime)

(slime-setup '(
	       slime-parse slime-mrepl
			   slime-autodoc
			   slime-references
			   slime-fancy))

;; flymake 

(require 'flymake)

;; I don't like the default colors :)

(set-face-background 'flymake-errline "red4")
(set-face-background 'flymake-warnline "dark slate blue")

;; Invoke ruby with '-c' to get syntax checking
(defun flymake-ruby-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
	 (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "ruby" (list "-c" local-file))))

(push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)

(push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)

(add-hook 'ruby-mode-hook
          '(lambda ()
	     
	     ;; Don't want flymake mode for ruby regions in rhtml files and also on read only files
	     (if (and (not (null buffer-file-name)) (file-writable-p buffer-file-name))
		 (flymake-mode))
	     ))
;; Multiterm

(autoload 'multi-term "multi-term" nil t)
(autoload 'multi-term-next "multi-term" nil t)

(setq multi-term-program "/bin/zsh") ;; use zsh

;; only needed if you use autopair

(add-hook 'term-mode-hook
	  #'(lambda () (setq autopair-dont-activate t)))

(global-set-key (kbd "C-c t") 'multi-term-next)
(global-set-key (kbd "C-c T") 'multi-term) ;; create a new one

