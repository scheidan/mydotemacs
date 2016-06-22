;;; -------------------------------------------------------
;;;
;;; .emacs - global file, saved on dropbox
;;;
;;; Andreas Scheidegger
;;; -------------------------------------------------------

;;; -----------
;;  The variable 'path-cloud' must be defined in the LOCAL init file
;;  example:
;;  (setq path-cloud "C:/Users/scheidan/Dropbox")

;; The packages are installed and loaded with the package "req-package"
;; Hence this package must be installed manually at first.


;;; ---------------------------------
;;; manages packages

;; -----------
;; install package "use-package"
(package-initialize)

;; (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
;; (add-to-list 'package-archives '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/") t)

(setq package-enable-at-startup nil)
(unless (package-installed-p 'req-package)
  (package-refresh-contents)
  (package-install 'req-package))


(eval-when-compile
  (require 'req-package))

;;; ---------------------------------
;;; Fx: global hot-keys

;; F1: Bookmarks
;; F2: Deft
;; F3: code folding
;; F4:

;; F5: toogle relative/absolute line numbers

;; F6: insert date
(setq system-time-locale "C")
(defun today ()
  "Insert string for today's date or updates date
in the line of the cursor."
  (interactive)
  (setq cursor-now (point))
  (setq searchdate "\\(January\\|February\\|March\\|April\\|May\\|June\\|July\\|August\\|September\\|October\\|November\\|December\\) [ 0-9][0-9], [0-9]\\{4\\}")
  (goto-char (line-beginning-position))
  (if (search-forward-regexp searchdate (line-end-position) t)
      (replace-match (format-time-string "%B %e, %Y") t t)
    (goto-char cursor-now)
    (insert (format-time-string "%B %e, %Y"))
    )
  (goto-char cursor-now)
  )

(global-set-key [f6] 'today)

;; F7: insert path of current file
(defun insert-dir-name (dir)
  (interactive "D")
  (insert dir))
(global-set-key [f7] 'insert-dir-name)

;; F8: spell checking

;; F10
(global-set-key [f10] 'magit-status)

;; F11
(global-set-key [f11] 'compile)

;; F12




;;; ---------------------------------
;;; misc things with global effect


(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)		; Remove splash screen
(setq inhibit-startup-message t)

(fset 'yes-or-no-p 'y-or-n-p)		;type only 'y' or 'n'
(add-hook 'text-mode-hook 'turn-on-visual-line-mode) ; for resonable line wrapping
(add-hook 'text-mode-hook 'turn-on-auto-fill) ; wrap long lines in text mode
(setq scroll-error-top-bottom t)		     ; do not send error if no scolling is possible
(setq dabbrev-case-fold-search nil)		     ; make auto-completion case sensitive
(global-font-lock-mode t)		; syntax highlighting
(show-paren-mode t)			; match parentheses
;; (setq show-paren-style 'expression)	; highlight whole expression between parentheses
(transient-mark-mode t)			; sane select (mark) mode
(delete-selection-mode t)		; entry deletes marked text
(setq make-backup-files nil)		; make no backup files
(pending-delete-mode 1)			; replace marked text when typing

;; ---  remove trailin whitespaces before saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; --- make script files executable
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; don't let the cursor go into minibuffer prompt:
(setq minibuffer-prompt-properties (
				    quote (read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt)
					  ))


;; --- split windows and change focus
(defun split-window-below-jump ()
  (interactive)
  (split-window-below)
  (other-window 1))

(defun split-window-right-jump ()
  (interactive)
  (split-window-right)
  (other-window 1))

(global-set-key (kbd"C-x 2") 'split-window-below-jump)
(global-set-key (kbd"C-x 3")  'split-window-right-jump)

;; --- ediff option
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)


;;--- hydra ---
(req-package hydra
  :config (progn
	    (defhydra hydra-bookmark (:exit t)
	      "Manage bookmarks"
	      ("l" bookmark-bmenu-list "list")
	      ("a" bookmark-set "add")
	      ("s" bookmark-save "save"))

	    (defhydra hydra-color-theme (:exit nil)
	      "Select colort heme"
              ("l" set-light-theme "light")
	      ("d" set-dark-theme "dark"))

	    (defhydra hydra-other-window (:body-pre (other-window 1))
	      "change window"
	      ("o" (other-window 1) "next")
	      ("p" (other-window -1) "previous"))

	    (defhydra hydra-text (:exit nil)
	      ("t" toggle-truncate-lines "truncate line")
	      ("w" visual-line-mode "word wrap line")
	      ("s" whitespace-mode "whitespace")
	      ("a" auto-fill-mode "toggle auto-fill")
	      ("q" nil "quit"))

	    (defhydra hydra-expand-region (:body-pre (er/expand-region 1))
	      "mark region"
	      ("=" er/expand-region "expand")
	      ("-" er/contract-region "contract"))

	    (defhydra hydra-multiple-cursors (:hint nil :exit nil)
	      "
[_p_]   next    [_n_]   next    [_l_] edit lines
[_P_]   skip    [_N_]   skip    [_a_] mark all  [_q_] quit"
	      ("l" mc/edit-lines :exit t)
	      ("a" mc/mark-all-like-this :exit t)
	      ("n" mc/mark-next-like-this)
	      ("N" mc/skip-to-next-like-this)
	      ("p" mc/mark-previous-like-this)
	      ("P" mc/skip-to-previous-like-this)
	      ("q" nil))
	    )


  :bind (("<f1>" . hydra-bookmark/body)
         ("C-x o" . hydra-other-window/body)
         ("<f12>" . hydra-color-theme/body)
	 ("<f4>" . hydra-text/body)
	 ("C-=" . hydra-expand-region/body)
	 ("C-x =" . hydra-expand-region/body)
	 ("C--" . hydra-multiple-cursors/body))
  )



;; --- better commenting
(req-package comment-dwim-2
  :bind ("M-;" . comment-dwim-2)
  )

;;--- dired improvements ---
(req-package dired-subtree
  )


;;--- line numbers ---


(req-package nlinum
  :defer t
  )


;; relative numbers
(req-package nlinum-relative
  :require nlinum
  :defer t
  )


(defun toggle-li (n)
  "Cycle through linum, linum relative, and no linum"
  (interactive "p")
  ;; uses a property “state”. Value is a integer.
  (let* (
         (values [nlinum-relative-off  nlinum-relative-on nlinum-mode])
	 (index-before
	  (if (get 'toogle-li 'state)
	      (get 'toogle-li 'state)
	    0))
	 (index-after (% (+ index-before (length values) n) (length values)))
	 (next-value (aref values index-after)))
    (put 'toogle-li 'state index-after)	;save 'state'

    (if (eq index-after 2)
        (funcall next-value 0)		;disable linum mode
      (progn
	(nlinum-mode)			;enable linum mode
	(funcall next-value)))		;enabel/disable relative
    ))

(global-set-key [f5] 'toggle-li)


;; --- mouse scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed 't) ;;  accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

;;  --- expansion
(global-set-key "\M-/" 'hippie-expand)	; use better expand (for file names, ... too)
(setq hippie-expand-try-functions-list '( ; order of completion
					 try-expand-dabbrev
					 try-expand-list
					 try-complete-file-name-partially
					 try-complete-file-name
					 try-expand-dabbrev-visible
					 try-expand-dabbrev-all-buffers
					 try-expand-dabbrev-from-kill))

;; --- auto correction with abbrev
;;

(setq abbrev-file-name             ;; tell emacs where to read abbrev
      (concat path-cloud "/" "Emacs/abbrev/myabbrev.el"))

(setq save-abbrevs t)			;save added abbrev automatically
(add-hook 'text-mode-hook (lambda () (abbrev-mode 1)))
(add-hook 'latex-mode-hook (lambda () (abbrev-mode 1)))



;; --- god mode
(req-package god-mode
  :disabled t
  :ensure t
  :config (progn
	    (defun my-update-cursor ()
	      (setq cursor-type (if (or god-local-mode buffer-read-only)
				    'bar
				  'box)))
	    (add-hook 'god-mode-enabled-hook 'my-update-cursor)
	    (add-hook 'god-mode-disabled-hook 'my-update-cursor)

	    )
  :bind (
	 ("<escape>" . god-local-mode)
	 ;; ("<escape>" . god-mode-all)
	 )

  )


;; --- company mode

(req-package company
  :diminish company-mode
  :config (progn
	    (global-company-mode)
	    (company-statistics-mode))
  )

(req-package company-quickhelp
  :require company
  :config (company-quickhelp-mode 1)
  )

(req-package company-statistics
  :require company
  :config (company-quickhelp-mode 1)
  )



;; --- expand region
(req-package expand-region
  :defer t
  ;; :bind (("C-=" . er/expand-region))
  )

;; --- smartparens
(req-package smartparens
  :diminish smartparens-mode
  :config (smartparens-global-mode)
  :bind (("C-S-f" . sp-slurp-hybrid-sexp)
	 ("C-S-b" . sp-forward-barf-sexp)
	 ("C-k" . sp-kill-hybrid-sexp))	;kill line but keep parentheses balanced
  )


;; --- copy a text but remove extra whitespace and new lines (e.g. to copy it into Word)

(defun word-copy (&optional beg end)
  "Save the current region (or line) to the `kill-ring' after stripping extra whitespace and new lines"
  (interactive
   (if (region-active-p)
       (list (region-beginning) (region-end))
     (list (line-beginning-position) (line-end-position))))
  (let ((my-text (buffer-substring-no-properties beg end)))
    (with-temp-buffer
      (insert my-text)
      (goto-char 1)
      (while (looking-at "[ \t\n]")
	(delete-char 1))
      (let ((fill-column 9333999))
	(fill-region (point-min) (point-max)))
      (kill-region (point-min) (point-max)))))


;; --- name similar buffer in a good way
(req-package uniquify
  :defer t
  :config
  (setq
   uniquify-buffer-name-style 'post-forward
   uniquify-separator "|"
   uniquify-after-kill-buffer-p t ; rename after killing uniquified
   uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers
  )


;; --- kill the whole word with M-d
(defun kill-whole-word ()
  "Select the word under cursor and kill it 'word' here is considered
any alphanumeric sequence with '_', '.' or '-' and delte unnecessary spaces."
  (interactive)
  (let (p1 p2)
    (skip-chars-backward "-\._A-Za-z0-9")
    (setq p1 (point))
    (skip-chars-forward "-\._A-Za-z0-9")
    (setq p2 (point))
    (kill-region p1 p2)
    (if (looking-at "[ \t\n]")
	(just-one-space 1)
      (just-one-space 0)
      )
    ))
(global-set-key (kbd"M-d") 'kill-whole-word)


;; --- delete one or all spaces
(global-set-key (kbd"M-SPC") 'cycle-spacing)


;; --- kill always current buffer
(defun kill-this-buffer ()
  (interactive)
  (kill-buffer (current-buffer)))
(global-set-key (kbd "C-x k") 'kill-this-buffer)


;; --- aggressive-indent-mode
(req-package aggressive-indent
  :diminish aggressive-indent-mode
  :config (global-aggressive-indent-mode 1)
  )


;;; ---------------------------------
;;; visual things

;;---  useful frame titles ---
(setq frame-title-format "%b")
(setq icon-title-format "%b")

;;;--------------------
;;;--- color themes ---

(req-package color-theme-sanityinc-tomorrow
  )

(req-package color-theme-sanityinc-solarized
  )

(req-package material-theme
  )

(load-theme 'material t)

(defun set-light-theme ()
  (interactive)
  ;; (load-theme 'material-light t)
  (load-theme 'sanityinc-tomorrow-day t)
  (powerline-reset)
  (set-face-background 'highlight-indentation-current-column-face "#fffacd")
  )

(defun set-dark-theme ()
  (interactive)
  (load-theme 'material t)
  ;; (load-theme 'sanityinc-tomorrow-eighties t)
  (powerline-reset)
  (set-face-background 'highlight-indentation-current-column-face "#212121")
  )


;; --- highlight cursor line ---
(global-hl-line-mode 1)
(set-face-foreground 'highlight nil) 	; keep syntax highlighting

;; --- highlight cursor if changing buffer
(req-package beacon
  :config (beacon-mode 1)
  )



;; --- mode line ---

(defun spaceline--theme (left second-left &rest additional-segments)
  "Convenience function for the spacemacs and emacs themes."
  (spaceline-install

   `(,left
     anzu
     auto-compile
     ,second-left
     major-mode
     (process :when active)
     ((flycheck-error flycheck-warning flycheck-info)
      :when active)
     ((minor-modes :separator spaceline-minor-modes-separator)
      :when active)
     (mu4e-alert-segment :when active)
     (erc-track :when active)
     (version-control :when active)
     (org-pomodoro :when active)
     (org-clock :when active)
     nyan-cat)

   `(which-function
     (python-pyvenv :fallback python-pyenv)
     (battery :when active)
     selection-info
     input-method
     ((buffer-encoding-abbrev
       point-position
       line-column)
      :separator " | ")
     (global :when active)
     ,@additional-segments
     buffer-position
     hud)))

(req-package spaceline
  :init (defadvice vc-mode-line (after strip-backend () activate) ; make nice branch logo
	  (when (stringp vc-mode)
	    (let ((gitlogo (replace-regexp-in-string "^ Git." "  " vc-mode)))
	      (setq vc-mode gitlogo))))

  :config (setq
	   powerline-default-separator 'wave
	   spaceline-buffer-size-p nil
	   spaceline-minor-modes-p nil
	   spaceline-line-p t)
  )

(require 'spaceline-config)
; (spaceline-emacs-theme)
(spaceline-spacemacs-theme)



;;; ----------------------
;;; yasnippet

(req-package yasnippet
  :diminish yas-minor-mode
  :init  (setq yas-snippet-dirs (list
				 (concat path-cloud "/" "Emacs/snippets/mysnippets")
				 (concat path-cloud "/" "Emacs/snippets/yasnippet-snippets")
				 ))
  :config (progn
	    (yas-global-mode 1)
	    (define-key yas-minor-mode-map (kbd "<tab>") nil)
	    (define-key yas-minor-mode-map (kbd "TAB") nil)
	    (define-key yas-minor-mode-map [(tab)] nil)
	    (define-key yas-minor-mode-map (kbd "C-<tab>") 'yas-expand) ;set C-tab to expand
	    )
  )


;;; ----------------------
;;; flycheck

;; install manually linter
;; - python: flake8
(req-package flychec
  :disabled t
  ;; :init (global-flycheck-mode)
  )


;;; ----------------------
;;; Magit and co

(req-package magit
  ;; :bind (<f10> . magit-status)
  )


(req-package git-timemachine
  )



;;; ----------------------
;;; --- projectile

(req-package projectile
  :diminish projectile-mode
  :config (progn
	    (projectile-global-mode)
	    (setq projectile-completion-system 'helm)
	    (setq projectile-enable-caching nil) ;if t enable caching
	    (setq projectile-indexing-method 'alien) ; use external index tool
	    ;; order for nested project (see https://github.com/bbatsov/projectile/issues/308)
	    (setq projectile-project-root-files-functions '(projectile-root-top-down)
		  projectile-project-root-files
		  '(".git" ".bzr" ".svn" ".hg" "_darcs" ".projectile" "Makefile"))

	    ;; Remove dead projects when Emacs is idle
	    (run-with-idle-timer 10 nil #'projectile-cleanup-known-projects)

	    ;; special find-file
	    (defun find-file-all-project ()
	      "find file for all files in project folder"
	      (interactive)
	      (projectile-switch-project-by-name (concat path-cloud "/" "Projects") )
	      )

	    )
  :bind (
	 ("C-x C-a" . find-file-all-project)
	 )
  )


(req-package helm-projectile
  :require helm projectile
  :ensure t
  :config (progn
	    (helm-projectile-on)		;turn on keybindings
	    (setq projectile-switch-project-action 'helm-projectile-find-file)
	    )
  :bind ("C-c h" . helm-projectile)
  )

;;; ----------------------
;;; --- helm mode

(req-package helm
  :diminish helm-mode
  :config
  (progn
    (require 'helm-config)
    (setq helm-candidate-number-limit 100)
    ;; From https://gist.github.com/antifuchs/9238468
    (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
	  helm-input-idle-delay 0.01  ; this actually updates things
					; reeeelatively quickly. ; ; ;
	  helm-quick-update t
	  helm-ff-auto-update-initial-value t ;update path in helm-file-find as soon it is unique
	  ;; enable fuzzy matching
	  helm-M-x-fuzzy-match t
	  helm-buffers-fuzzy-matching t
	  helm-recentf-fuzzy-match t
	  ;; add bookmakrs to helm-mini
	  helm-mini-default-sources '(helm-source-buffers-list
				      helm-source-recentf
				      helm-source-bookmarks
				      helm-source-buffer-not-found)
	  )

    (helm-mode 1)

    ;; search notes
    (defun grep-notes  ()
      "run grep in all files of the notes directory"
      (interactive)
      (let
	  ((files (helm-walk-directory (concat path-cloud "/" "Emacs/notes")
				       :path 'full
				       :directories nil
				       :match ".*\\.txt$"
				       :skip-subdirs t)))
	(helm-do-grep-1 files)))
    )

  :bind (
	 ("M-x" . helm-M-x)
	 ("C-x C-f" . helm-find-files)
	 ("M-y" . helm-show-kill-ring)
	 ("C-x b" . helm-mini)
	 ("C-x C-b" . helm-mini)
	 ("C-x C-f" . helm-find-files)
	 ("M-i" . helm-semantic-or-imenu)
	 ("C-x C-n" . grep-notes)
	 )
  )

;; --- helm-ag

;; requires ag, "the silver search"
;; https://github.com/ggreer/the_silver_searcher
(req-package helm-ag
  :require helm
  :bind ("C-c g" . helm-do-ag)
  )

;; --- helm-swoop

(req-package helm-swoop
  :require helm
  :defer t
  :bind (
	 ("M-o" . helm-swoop)
	 ("M-O" . helm-swoop-back-to-last-point)
	 ("C-c M-o" . helm-multi-swoop)
	 ("C-x M-o" . helm-multi-swoop-all)
	 )

  :config
  (progn
    (define-key isearch-mode-map (kbd "M-o") 'helm-swoop-from-isearch)
    (define-key helm-swoop-map (kbd "M-o") 'helm-multi-swoop-all-from-helm-swoop)


    ;; Save buffer when helm-multi-swoop-edit complete
    (setq helm-multi-swoop-edit-save t)

    ;; If this value is t, split window inside the current window
    (setq helm-swoop-split-with-multiple-windows nil)

    ;; Split direcion. 'split-window-vertically or 'split-window-horizontally
    (setq helm-swoop-split-direction 'split-window-vertically)

    ;; If nil, you can slightly boost invoke speed in exchange for text color
    (setq helm-swoop-speed-or-color t)

    ;; ;; disable pre-input
    ;; (setq helm-swoop-pre-input-function
    ;; 	  (lambda () ""))
    )
  )

;; --- helm-swoop

(req-package helm-descbinds
  :require helm
  :defer t
  :config (setq helm-descbinds-mode t)
  )


;;; ---------------------------------
;;; --- ISEARCH
;; jump to beginning of a match

(add-hook 'isearch-mode-end-hook 'my-goto-match-beginning)
(defun my-goto-match-beginning ()
  (when (and isearch-forward isearch-other-end)
    (goto-char isearch-other-end)))

(defadvice isearch-exit (after my-goto-match-beginning activate)
  "Go to beginning of match."
  (when (and isearch-forward isearch-other-end)
    (goto-char isearch-other-end)))


;; --- multiple-cursors (see hydra)
(req-package multiple-cursors
  )


;; --- visual-regexp: replace with visual feedback
;; https://github.com/gbenma/visual-regexp.el/
(req-package visual-regexp
  :defer t
  :bind (("C-M-%" . vr/query-replace))
  )

;; ---------------------------------
;; --- clojure set-up


(req-package clojure-mode
  )


; REPL
(req-package cider
  )

;;; ---------------------------------
;;; org mode

(req-package org
  :defer t
  :config
  (progn

    ;; use color highlighting for code  blocks
    (setq org-src-fontify-natively t
	  org-src-tab-acts-natively t
	  org-confirm-babel-evaluate nil)

    ;; ;; separate source blocks in org mode
    ;; (defface org-block-begin-line
    ;;   '((t (:underline "#A7A6AA" :foreground "#008ED1" :background "#EAEAFF")))
    ;;   "Face used for the line delimiting the begin of source blocks.")

    ;; (defface org-block-background
    ;;   '((t (:background "#FFFFEA")))
    ;;   "Face used for the source block background.")

    ;; (defface org-block-end-line
    ;;   '((t (:overline "#A7A6AA" :foreground "#008ED1" :background "#EAEAFF")))
    ;;   "Face used for the line delimiting the end of source blocks.")

    ;; evaluate code of this languages
    (org-babel-do-load-languages
     'org-babel-load-languages
     '( (R . t)
	(python . t)
	(emacs-lisp . t)
	(julia . t)
	))

    ;; instead of *** use indented *
    (add-hook 'org-mode-hook
	      (lambda ()
		(org-indent-mode t))
	      t)

    ;; enable inline images
    (add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
    (add-hook 'org-mode-hook 'org-display-inline-images)

    )
  )


;; org download to manage images
(req-package org-download
  :require org
  :config (setq org-download-timestamp "")
  )


;;; ---------------------------------
;;; deft mode for notes

(req-package deft
  :defer t
  :config (progn
	    (setq
	     deft-extensions '("org" "txt" "gpg")
	     deft-directory (concat path-cloud "/" "Emacs/notes/")
	     deft-text-mode 'org-mode
	     deft-use-filename-as-title t)
	    )
  :bind (("<f2>" . deft))
  )
;; (deft)					; show deft buffer at start-up


;;; ----------------------
;;; python settings

(setq python-shell-interpreter "ipython") ; use ipython

(defun my-python-send-line ()
  "eval line, don't move cursor'"
  (interactive)
  (end-of-line)
  (set-mark (line-beginning-position))
  (call-interactively 'python-shell-send-region))

(defun my-python-mode-hook ()
  ;; highlight some bad keywords...
  (font-lock-add-keywords nil
			  '(("\\<\\(BUG\\|bug\\|[!]\\{3,\\}\\|hack\\|HACK\\)" 1 font-lock-warning-face t)))
  ;; keys...
  (local-set-key (kbd "C-c C-l") 'my-python-send-line)
  (local-set-key (kbd "C-c C-b") 'python-shell-send-buffer))

(add-hook 'python-mode-hook 'my-python-mode-hook)


(req-package highlight-indentation
  :init (add-hook 'python-mode-hook
		  'highlight-indentation-current-column-mode)
  :config (set-face-background 'highlight-indentation-current-column-face "#2f4f4f")
  )


;; ;;; -------------
;; ---------
;; jedi for python

;; virtualenv must be installed before: https://virtualenv.pypa.io/en/latest/

(req-package company-jedi
  :require company, company-quickhelp
  :init
  (defun my/python-mode-hook ()
    (add-to-list 'company-backends 'company-jedi))
  (add-hook 'python-mode-hook 'my/python-mode-hook)
  :config (add-hook 'python-mode-hook 'my/python-mode-hook)
  )
;;(add-hook 'python-mode-hook 'my/python-mode-hook)


;; --- Elpy
;; maybe a better setup
;; (req-package elpy
;;   :init (progn (elpy-enable)
;; 	       (elpy-use-ipython))

;;   )

;;; ---------------------------------
;;; autoinsert - include headers automatically in new files

(require 'autoinsert)

(auto-insert-mode 1)			; insert text but do not modify the file
(setq auto-insert 1)		     ; insert if possible, but mark as unmodified
(add-hook 'find-file-hooks 'auto-insert) ; autoinsert in new files
(setq auto-insert-query nil)		 ; always insert template

;; where are the templates? -> "path-cloud" is defined in LOCAL init file
(setq auto-insert-directory (concat path-cloud "/" "Emacs/templates/"))


;; mapping of mode or file types to template files
(setq auto-insert-alist
      '((ess-mode . ["template.R" auto-update-header-file]) ; Julia and R code
	(python-mode . ["template.py" auto-update-header-file]) ;python
	("\\.\\(tex\\|Rnw\\)$" . ["template.tex" auto-update-header-file]) )); LaTeX or Sweave files

;; function to replaces in the header the string '@@@' by the current file
;; name, '&&&' by the path,  and 'DDDD' by the date.
(defun auto-update-header-file ()
  "include file name for '@@@'"
  (save-excursion
    (while (search-forward "@@@" nil t)
      (save-restriction
	(narrow-to-region (match-beginning 0) (match-end 0))
	(replace-match (file-name-nondirectory buffer-file-name))
	))
    )
  "include path for '&&&'"
  (save-excursion
    (while (search-forward "&&&" nil t)
      (save-restriction
	(narrow-to-region (match-beginning 0) (match-end 0))
	(replace-match (file-name-directory buffer-file-name))
	))
    )
  (save-excursion
    "replace DDDD with today's date"
    (while (search-forward "DDDD" nil t)
      (save-restriction
	(narrow-to-region (match-beginning 0) (match-end 0))
	(replace-match "")
	(today)				;(today) is defined above in this file
	))
    )
  )


;;; ---------------------------------
;;; ESS


(req-package ess-site
  :ensure ess
  :mode ("\\.r\\'" . R-mode)
  :commands R
  :init (progn
	  ;; highlight some bad keywords...
	  (add-hook 'ess-mode-hook
		    (lambda ()
		      (font-lock-add-keywords nil
					      '(("\\<\\(BUG\\|bug\\|[!]\\{3,\\}\\|hack\\|HACK\\)" 1 font-lock-warning-face t)))))
	  )
  :config (progn
	    ;; load debug mode (now included in ESS)
	    ;; see also "http://code.google.com/p/ess-tracebug/"
	    (setq ess-tracebug-prefix "\M-c")
	    (setq ess-use-tracebug t)

	    ;;(add-hook 'ess-post-run-hook 'ess-tracebug t)
	    (setq ess-busy-strings ess--busy-stars)	; for progress bar

	    ;; Path to R executable.
	    ;; And keep updating with each R update!
	    ;; set enviromental variables at the end
	    ;; -> see LOCAL init file
	    ;; (setq-default inferior-R-program-name
	    ;;               "c:/program files/r/r-2.15.0/bin/x64/rterm.exe" LANGUAGE=en)

	    ;; start up arguments for R
	    ;; don't save command history and workspace
	    (setq-default inferior-R-args "--no-restore --no-save")

	    ;; start up arguments for julia
	    (setq-default inferior-julia-args "--no-history-file")

	    ;; auto-complete
	    (setq ess-use-auto-complete t)

	    ;; Set code indentation following the standard in R sources.
	    (setq ess-default-style 'DEFAULT)
	    (ess-set-style 'DEFAULT 'quiet) ; set the style for CURRENT buffer

	    ;; scroll buffer automatically
	    (setq comint-scroll-to-bottom-on-output t)
	    (setq comint-scroll-to-bottom-on-input t)

	    ;; do not echo code
	    (setq ess-eval-visibly-p nil)

	    ;; other small ESS options
	    (setq ess-ask-for-ess-directory nil)
	    (setq comint-move-point-for-output t)	; scoll output

	    ;; define function to send all code above cursor
	    (defun ess-eval-above ()
	      "Sends all code above cursor."
	      (interactive)
	      (set-mark 1)
	      (call-interactively 'ess-eval-region)
	      )

	    ;; define function to send all code below cursor
	    (defun ess-eval-below ()
	      "Sends all code below cursor."
	      (interactive)
	      (set-mark (point-max))
	      (call-interactively 'ess-eval-region)
	      )

	    )
  :bind (:map ess-mode-map
	      ("\C-c\C-a" . ess-eval-above)
	      ("\C-c\C-u" . ess-eval-below))
  )

(req-package ess-eldoc
  :ensure ess
  )

(req-package ess-jags-d
  :ensure ess
  )



;; formats comments of R files and reindent
(defun format-R-comments ()
  "Formate R comments in emacs style. Also make spaces around '<-'."
  (interactive)
  (save-excursion
    ;; search lines beginning with a single hash
    (setq single-hashs "^[[:space:]]*\\(#\\)[^#]")
    (goto-char (point-min))
    (while (search-forward-regexp single-hashs nil t)
      (replace-match "##" t t nil 1)
      )

    ;; make only one hash after code
    (setq too-many-hashs "[[:graph:]]+[[:space:]]*\\(##+\\)")
    (goto-char (point-min))
    (while (re-search-forward too-many-hashs nil t)
      ;; replace the last part of the match with '#'
      (replace-match "#" t t nil 1)
      )

    ;; search hash without a following space
    (setq hashs-no-space "\\(#\\)[^[:space:]#]")
    (goto-char (point-min))
    (while (re-search-forward hashs-no-space nil t)
      (replace-match "# " t t nil 1)
      )

    ;; make spaces around "<-"
    (setq assigns "[[:space:]]*<-[[:space:]]*")
    (goto-char (point-min))
    (while (re-search-forward assigns nil t)
      (replace-match " <- " t t)
      )
    ;; intend and clean buffer
    (save-excursion
      (delete-trailing-whitespace)
      (indent-region (point-min) (point-max) nil)
      (untabify (point-min) (point-max))
      )
    )
  )


;;; ---------------------------------
;;; --- move selected region ---


(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg)
          ;; Account for changes to transpose-lines in Emacs 24.3
          (when (and (eval-when-compile
                       (not (version-list-<
                             (version-to-list emacs-version)
                             '(24 3 50 0))))
                     (< arg 0))
            (forward-line -1)))
        (forward-line -1))
      (move-to-column column t)))))


(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))


(global-set-key [\M-\S-up] 'move-text-up)
(global-set-key [\M-\S-down] 'move-text-down)


;;; ---------------------------------
;;; --- Code folding ---

(defun jao-selective-display ()
  "Activate selective display based on the column at point"
  (interactive)
  (set-selective-display
   (if selective-display
       nil
     (+ 1 (current-column)))))

(global-set-key [f3] 'jao-selective-display)



;;; ---------------------------------
;;; AUCTeX and reftex
;;;

(req-package tex-site
  :ensure auctex
  :mode ("\\.tex\\'" . TeX-latex-mode)
  :defer t
  :config (progn

	    (setq TeX-auto-save t)
	    (setq TeX-parse-self t)
	    (setq TeX-PDF-mode t)

	    ;; Turn on RefTeX for LaTeX documents. Put further RefTeX
	    ;; customizations in your .emacs file.
	    (add-hook 'LaTeX-mode-hook
		      (lambda ()
			(turn-on-reftex)
			(setq reftex-plug-into-AUCTeX t)))

	    ;; Add standard Sweave file extensions to the list of files recognized
	    ;; by AUCTeX.
	    (setq TeX-file-extensions
		  '("Rnw" "rnw" "Snw" "snw" "tex" "sty" "cls" "ltx" "texi" "texinfo" "dtx"))

	    ;; natbib citations
	    (setq reftex-cite-format 'natbib)

	    ;; sort BibTex entries alphabetically
	    (setq bibtex-maintain-sorted-entries t)

	    )
  )




;;; ---------------------------------------------
(req-package-finish)
