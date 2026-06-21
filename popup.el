;;; popup.el --- Runs helper tool within popup window -*- lexical-binding: t; -*-
;;
;; Author: Diacus Magnuz <diacus.magnuz@gmail.com>
;; URL: https://github.com/diacus/popup.el
;;; Commentary:
;;
;; popup.el runs a custom repl inside a temporary popup window
;;
;;; Code:
(defmacro make-repl-popup (repl-function)
  "Run REPL-FUNCTION that inside a pop-up window."
  `(lambda (&rest args)
     (interactive)
     (let ((display-buffer-alist
            '(("\\*.*\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.3))))
           (old-buffers (buffer-list)))
       ;; 1. Run the REPL function
       (apply ,repl-function args)
       ;; 2. Identify the newly created REPL buffer
       (let* ((new-buffers (cl-set-difference (buffer-list) old-buffers))
              (repl-buf (car new-buffers))
              (proc (and repl-buf (get-buffer-process repl-buf))))
         (when proc
           ;; 3. Attach a sentinel to watch for process exit
           (set-process-sentinel
            proc
            (lambda (p event)
              (when (string-match-p "\\(?:status\\|exited\\|finished\\)" event)
                (let ((buf (process-buffer p)))
                  (when (buffer-live-p buf)
                    ;; Kill the buffer, which automatically closes the side window
                    (kill-buffer buf)))))))))))

;;; popup.el ends here
