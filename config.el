(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell.

This is particularly useful under Mac OSX, where GUI apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

;;Make sure that everything is up to date
(when (>= emacs-major-version 24)
  (require 'package)
  ;;(require 'melpa)
  
  (defvar packages '(let-alist flycheck cuda-mode jedi ggtags helm-gtags projectile
			       helm-projectile-all helm-projectile
			       company-c-headers haskell-mode base16-theme monokai-theme
			       company helm-flycheck helm-ghc auctex
			       company-auctex latex-preview-pane
			       nlinum))

  
  ;; list the repositories containing them
  ;;(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

  (setq check-signature nil)
  ;; activate all the packages (in particular autoloads)
  (package-initialize)
  
  ;; fetch the list of packages available 
  (unless package-archive-contents
    (package-refresh-contents))

  ;;;; install the missing packages
  (dolist (package packages)
    (unless (package-installed-p package)
    (package-install package)))
  )



;;;;;;;;;;;;;;;
;;Emacs Theme;;
;;;;;;;;;;;;;;;
(defun gTheme ()
  (unwind-protect
      (set-frame-font "Droid Sans Mono 12")
    (message "Please install Droid Sans Mono"))
  (set-cursor-color "white")
  (load-theme 'base16-monokai 1)
  )

(if (display-graphic-p (selected-frame))
    (gTheme)
  )


(tool-bar-mode -1)
(menu-bar-mode -1) 
(setq mac-command-modifier 'meta)
;;Stupid fringe and scroll bar
(scroll-bar-mode -1)
(set-fringe-mode 0)
;;We don't wrap lines
(setq-default truncate-lines t)

;;;;;;;;;;;;;;
;;Some modes;;
;;;;;;;;;;;;;;

(require 'helm-config)
(global-flycheck-mode)
(global-company-mode 1)
(helm-mode)
(helm-autoresize-mode 1)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(define-key flycheck-mode-map (kbd "C-;") 'helm-flycheck)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t)

;;;;;;;;;;;;;;;;;;;;;;
;;Emacs Python Stuff;;
;;;;;;;;;;;;;;;;;;;;;;
(defun jedi_config ()
  
  (require 'jedi)
  (jedi:setup)
  (setq jedi:setup-keys t)
  (setq jedi:complete-on-dot t)
  (setq jedi:get-in-function-call-delay 200)
  (company-mode 0)
  (if (executable-find "flake8")
      ()
    (message "Please install flake8"))
  (if (executable-find "epylint")
      ()
    (message "Please install epylint"))
  )

(add-hook 'python-mode-hook 'jedi_config)


;;;;;;;;;;;;;;;;;;;
;;Emacs c++ stuff;;
;;;;;;;;;;;;;;;;;;;
(require 'cc-mode)
;;(require 'cuda-mode)
(require 'company)
(require 'cl)

(add-hook 'after-init-hook 'global-company-mode)

(setq all-includes (list (expand-file-name "~/Dropbox/Fun/Vecky/src")
                         "/usr/local/cuda/include"))
 (add-hook 'prog-mode-hook 'nlinum-mode)
 
(projectile-global-mode)
(setq projectile-completion-system 'helm)
(helm-projectile-on)

(defun my-c++-config ()
  (setq flycheck-clang-include-path all-includes)
  (setq flycheck-clang-language-standard "c++11")
  (setq company-clang-arguments "-std=c++11")
  (define-key company-mode-map (kbd "C-:") 'helm-company)
  (define-key company-active-map (kbd "C-:") 'helm-company)
  (setq company-backends (delete 'company-semantic company-backends))
  (add-to-list 'company-backends 'company-c-headers)

  (ggtags-mode)
  (helm-gtags-mode)
  
  ;;Need to modify these to fit your system
  (add-to-list 'company-c-headers-path-system "/usr/local/include/c\+\+/4.9.2/")
  
  (define-key c-mode-map  (kbd "C-.") 'company-complete)
  (define-key c++-mode-map  (kbd "C-.") 'company-complete)
  )

(add-hook 'c-mode-hook 'my-c++-config)
(add-hook 'c++-mode-hook 'my-c++-config)


;;;;;;;;;;;;;;;;;;;;;;;
;;Emacs Haskell stuff;;
;;;;;;;;;;;;;;;;;;;;;;;

(require 'haskell-mode)


(add-hook 'haskell-mode-hook 'turn-on-haskell-unicode-input-method)

;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-decl-scan)


;;;;;;;;;;;;;;;;
;; Tramp stuff;;
;;;;;;;;;;;;;;;;

;; I compulsively backup so this is probably ok...
(setq auto-save-default nil)
(setq make-backup-files nil)

;;(setq temporary-file-directory "/Users/mmath/.emacs.d/backups")
;;(setq backup-directory-alist
;;      `((".*" . ,temporary-file-directory)))
;;(setq auto-save-file-name-transforms
;;      `((".*" ,temporary-file-directory t)))

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Tramp shouldn't be doing anything with version control
(setq vc-ignore-dir-regexp
      (format "\\(%s\\)\\|\\(%s\\)"
              vc-ignore-dir-regexp
              tramp-file-name-regexp))


;; Do local backups with tramp
(setq tramp-backup-directory-alist temporary-file-directory)

;; Use control master with tramp
(setq tramp-ssh-controlmaster-options
                (concat
                  "-o ControlPath=/tmp/address@hidden:%%p "
                  "-o ControlMaster=auto -o ControlPersist=yes"))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   (quote
    ((company-clang-arguments "-I/home/mmath/Dropbox/Fun/CudaTracer/src/" "-I/home/mmath/Dropbox/Fun/Vecky/src/")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
