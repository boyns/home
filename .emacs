;;; User
(setq user-mail-address "mboyns@qti.qualcomm.com"
      user-full-name "Mark Boyns")

;;; Packages
(require 'package)
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; Force ELPA packages to be loaded now
(setq package-enable-at-startup nil)
(package-initialize)

;;;
(push "~/lisp" load-path)
(require 'git)

;;; Bindings
(global-set-key "\C-cg" 'goto-line)
(global-set-key "\C-c " 'bury-buffer)
(global-set-key "\C-m" 'newline-and-indent)
(global-set-key "\C-cl" 'locate)
(global-set-key "\C-c\C-c" 'comment-dwim)
(global-set-key "\C-c%" 'paren-match)
(global-set-key "\C-cm" 'compile)
(when (display-graphic-p)
  (global-set-key "\C-z" 'undo)
  (global-set-key "\C-x\C-c" 'dont-do-that))

;;;
(fset 'yes-or-no-p 'y-or-n-p)
(defalias 'mkdir 'make-directory)

;;; Global Minor Modes
;; (beacon-mode 1)
;;(global-diff-hl-mode +1)
;; (add-hook 'dired-mode-hook 'diff-hl-dired-mode)
(global-git-gutter-mode +1)

;;; Whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; (add-hook 'c-mode-hook
;; 	  (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

;;; Coding Style
(defconst my-c-style
  '((c-tab-always-indent . nil)
    (c-auto-newline . t)
    (c-hanging-comment-starter-p . nil)
    (c-hanging-comment-ender-p . nil)
    (c-hanging-braces-alist        . ((class-open before after)
				      (defun-open)
				      (inline-open)
				      (inline-close)
				      (substatement-open)
				      (substatement-close)
				      (block-open)
				      (block-close)
				      (brace-list-open)))
    (c-basic-offset . 4)
    (c-hanging-colons-alist        . ((member-init-intro before)
				      (inher-intro before)
				      (case-label after)
				      (label after)
				      (access-label after)))
    (c-offsets-alist               . ((arglist-close     . c-lineup-arglist)
				      (inline-open       . 0)
				      (substatement-open . 0)
				      (statement-block-intro . +)
				      (block-open        . -)
				      (class-open        . 0)
				      (class-close       . 0)
				      (inexpr-class      . 0)
				      (defun-block-intro . +)
				      (access-label      . 0))))
  "my c style")
(c-add-style "my-c-style" my-c-style)

;; Customizations for all modes in CC Mode.
(defun my-c-mode-common-hook ()
  ;; set my personal style for the current buffer
  (c-set-style "my-c-style")
  ;; other customizations
  (setq tab-width 8
        ;; this will make sure spaces are used instead of tabs
        indent-tabs-mode nil)
  ;; we like auto-newline, but not hungry-delete
  (c-toggle-auto-newline 1))
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;;; Functions

;; Insert Java try-cache block.
(defun try-catch (point mark)
  "Insert a try-catch block around the selected region"
  (interactive "r")
  (let (min max)
    (save-excursion
      (save-restriction
	(narrow-to-region point mark)
	(goto-char (point-min))
	(beginning-of-line)
	(insert "try {\n")
	(goto-char (point-max))
	(insert "}\ncatch () {\n}\n")
	(setq min (point-min)
	      max (point-max))
	(widen)
	(indent-region min max nil)))
    (goto-char max)
    (search-forward "catch ()")
    (goto-char (- (match-end 0) 1))))

(defun getter-setter ()
  ""
  (interactive)

  ;; public or private
  (beginning-of-line)
  (forward-word 1)
  (setq p (point))
  (backward-word 1)
  (setq public (buffer-substring (point) p))

  (forward-word 2)
  (setq p (point))
  (backward-word 1)
  (setq type (buffer-substring (point) p))

  (forward-word 2)
  (setq p (point))
  (backward-word 1)
  (setq name (buffer-substring (point) p))

  (save-excursion
    (end-of-buffer)
    (search-backward "}")
    (setq p (point))
    (setq uppername (upcase-initials name))
    (insert "\npublic " type " get" uppername "() {\nreturn " name ";\n}\n\n")
    (insert "public void set" uppername "(" type " " name ")" " {\nthis." name " = " name ";\n}\n")
    (indent-region p (point) nil)))

;; Nice parentheses hack to mimic % under vi.
(defun paren-match ()
  "Jumps to the paren matching the one under point,
       and does nothing if there isn't one."
  (interactive)
  (cond ((looking-at "[\(\[{]")
	 (forward-sexp 1)
	 (backward-char))
	((looking-at "[])}]")
	 (forward-char)
	 (backward-sexp 1))
	(t (message "Could not find matching paren."))))

;;
(dolist (command '(yank yank-pop))
   (eval `(defadvice ,command (after indent-region activate)
            (and (not current-prefix-arg)
                 (member major-mode '(emacs-lisp-mode lisp-mode
                                                      clojure-mode    scheme-mode
                                                      haskell-mode    ruby-mode
                                                      rspec-mode      python-mode
                                                      c-mode          c++-mode
                                                      objc-mode       latex-mode
						      gradle-mode     java-mode
                                                      plain-tex-mode))
                 (let ((mark-even-if-inactive transient-mark-mode))
                   (indent-region (region-beginning) (region-end) nil))))))

;;; Custom
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-enabled-themes (quote (zenburn)))
 '(custom-safe-themes
   (quote
    ("7dad2be7d806486305d7d3afe6b53a0c882cf651e183ed1ffe6dfb0745dc80f6" "001d6425a6e5180a5e966d5be64b983e82dbf3fd92592f3637baa47ee59ba59e" "d0c4cea7365681d3b883f7e6459749ae1969325fb480cef9eb7cbc216f1b361d" default)))
 '(diff-hl-dired-extra-indicators nil)
 '(ediff-split-window-function (quote split-window-horizontally))
 '(electric-pair-mode t)
 '(git-gutter:update-interval 1)
 '(indicate-buffer-boundaries (quote left))
 '(make-backup-files nil)
 '(show-paren-mode t)
 '(show-paren-style (quote expression))
 '(speedbar-default-position (quote left))
 '(speedbar-tag-split-minimum-length 100)
 '(tool-bar-mode nil)
 '(tooltip-mode nil)
 '(visible-bell t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
