(require 'org) ; Use Org package
(find-file (concat user-emacs-directory "init.org")) ; Put init.org as initialization 
(org-babel-tangle) ; Extract just emacs-lisp source
(load-file (concat user-emacs-directory "init.el")) ; Insert the emacs-lisp from init.org to init.el
(byte-compile-file (concat user-emacs-directory "init.el")) ; Compile init.el for initialization.
