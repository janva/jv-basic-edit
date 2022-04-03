;;; jv-basic-edit.el --- Some basic text editing commands  -*- lexical-binding:t; -*-


;; Author: Janne Väisänen <janva415@gmail.com>
;; Created 26 Mar 2022
;; Version: 0.1

;; Keywords: elisp, textediting
;; URL:

;;; Commentary

;; This package provides the minor mode jv-basic-edit. It's a minimal package ;; consisting of a feew basic text editing commands such as copy whole line.  ;; This file is not part of GNU Emacs. This was part of me learning Elisp and how minor mode are built. Feel free to copy but be aware the code herein has its flaws and there are probably better solutions out there.

;; This file is free sofware...

;;;###autoload 


;;;;;;;;;;;;;;;;;;;;;;;;; Minor mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; To create a minor mode we need to have
;; a variable ending with -mode
;; a function with same name as variable
;; if we want it to be local to certain buffer set make-variable-buffer-localm

;;  In addtition we can enable keymaps by adding entries in minor-mode-map-alist.
;; should be pairs of minor modes symbol and keymap to be used

;;we can alsp enable lighter for minor-mode-alist
;; again usin minor mode variable symbol and

;; If we want to use hooks we then we can add it a variable initialized to nil
;; named modename-mode-hook. running the hooks can be done using

;;; Code:
;; (make-variable-buffer-local
(defvar jv-basic-edit-mode nil "Toggle jv-edit-basic-mode")
;; )

;; Create a structure to store your keybindings in
(defvar jv-basic-edit-mode-map (make-sparse-keymap) "The keymap for jv-edit-basic-mode")

;; Hooks on attached to this list will be run whenever mode is activated/deactivated
(defvar jv-basic-edit-mode-hook nil "The hook for jv-basic-edit-mode")

(define-key jv-basic-edit-mode-map (kbd "C-<return>") 'open-newline)
(define-key jv-basic-edit-mode-map (kbd "M-S-<down>") 'duplicate-line-down )
(define-key jv-basic-edit-mode-map (kbd "M-S-<up>" ) 'duplicate-line-up)
(define-key jv-basic-edit-mode-map (kbd "M-<down>")'swapline-down )
(define-key jv-basic-edit-mode-map (kbd "M-<up>")  'swapline-up )
;;register minor mode
(add-to-list 'minor-mode-alist '(jv-basic-edit-mode " jv-basic-edit"))

;;register keybingings map (associate with this mode) 
(add-to-list 'minor-mode-map-alist ( cons 'jv-basic-edit-mode jv-basic-edit-mode-map))

(defun jv-basic-edit-mode (&optional ARG)
  "jv-basic-edit-mode is a minor mode consisting of a few basic editing commands. If ARG positive number > 0  activate mode else deactivate.If ARG is 'toggle then toggle mode"
  (interactive (list 'toggle))
  (setq jv-basic-edit-mode
	(if (eq ARG 'toggle)
	    (not jv-basic-edit-mode)
	  (> ARG 0)))
  (if jv-basic-edit-mode
      (message "jv-basic-mode activated")
    (message "jv-basic-mode deactivated"))
  (run-hooks 'jv-basic-edit-mode-hook))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun open-newline (&optional n)
  "Opens a new line below current line even if cursor is in middle of current line.Move point to opened line. If N is set open n lines."
  (interactive "pNumber of lines to open: ")
  (goto-char (line-end-position))
	     (newline (or n 1)))
;; maybe refactor...
(defun copy-line ()
"Copy line(s) into kill-ring. "
(let ((beg (line-beginning-position))
      (end (line-end-position)))
    (save-excursion 
    (when mark-active
     (if (> (point) (mark))
 	 (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
       (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
     (copy-region-as-kill beg end))))


(defun duplicate--line (&optional direction)
  "Duplicates line(s) of text in DIRECTION. if DIRECTION is 1  duplicate to line bellow else duplicate to line abbove current line." 
  (save-mark-and-excursion
    (copy-line)
    (open-newline)
    (yank))
  (when (eq direction 1)
    (next-line)))
;;Fixme only works once for selected region since loosing the marked area when doing next line
(defun duplicate-line-down  ()
  "Creates newline(s) containing content of current line(s) below the current line. "
  (interactive)
  (duplicate--line 1))

(defun duplicate-line-up  ()
  "Creates  newline(s) containing content of current line(s) above the current line. "
  (interactive)
    (duplicate--line))

;; @deprecated new version handles region as well
;;(defun swapline-down (args)
;;  "Swaps current line with next line below. Point is set to beginning of line which was selected for swapping."
;;  (interactive "P")
;;      (kill-whole-line args)
;;      (unwind-protect
;;	  (next-line)
;;	(progn
;;  	  (beginning-of-line)
;;	  (save-excursion (yank)))))
;;

;; @deprecated
;;FIXME now make these work for region
;; FIXME need to handle readonly buffers
;; hmms seems buggy
;; (defun swapline-up (arg)
;;   "Swaps current line with previous line above."
;;   (interactive "P")
;;   (kill-whole-line arg)
;;   (unwind-protect 
;;       (previous-line)
;;   (beginning-of-line)
;;   (save-excursion (yank))))
;;FIXME should barf on read only buffers
(defun jv/kill--lines ()
  "Kill whole line(s). If mark is set kill all (whole)lines within region else kill line wher point is. "
  (let ((beg (line-beginning-position))
	;; could cas problems on last line of buffer
	(end (+ 1 (line-end-position))))
    ;; could take advantage of exchange-point and mark?
    (when mark-active
      ;; beg and end delimits  single line at this point it might be first
      ;; (if point < mark) or last if (point > mark)
      (if (> (point)(mark))
	  ;; If point is after mark then end is correct but beg is beginnging of last line
	  ;; mark is looking at characther on first line
	  (setq beg (save-excursion (goto-char (mark))(line-beginning-position)))
	;; if mark is after point end is currently last of first line and mark is at last line
	(setq end (save-excursion (goto-char (mark)) (+ (line-end-position) 1)))))
    (kill-region beg end))
  )

;; FIXME region is lost when command is executed through keybindings. Hence can do it repeatadly
;; FIXME should barf on readonly buffers
(defun swapline-down ()
  "Transposes whole line(s) down. POINT is set to begining of moved line."
  (interactive)
  (jv/kill--lines)
  ;;Similar to finally clause. If next-line tries to go beyon end of buffer
  ;; We still want to yank back the killed line. 
  (unwind-protect
      (next-line)
    (progn 
      (beginning-of-line)
      ;; preserve current point
      (save-mark-and-excursion(yank)))))

(defun swapline-up ()
  "Transpose line(s) up."
  (interactive)
  (jv/kill--lines)
  (unwind-protect

      (previous-line)
    (progn
      (beginning-of-line)
      (save-mark-and-excursion(yank))
  )))

(provide 'jv-basic-edit)


;;(transpose-regions)
;; 1
;; 2
;; 4
;; 3
;; 5

;;; jv-basic-edit.el ends here
;; two lines
;; (current-kill 0))
;; (barf-if-buffer-read-only)

;; (barf-if-buffer-read-only)
;; (barf-if-buffer-read-only)
