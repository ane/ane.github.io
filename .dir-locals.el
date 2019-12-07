((web-mode . ((eval . (progn
                        (setq-local web-mode-engines-alist '(("django" . "\\.html\\'")))
                        (put 'web-mode-engines-alist 'permanent-local t))))))
