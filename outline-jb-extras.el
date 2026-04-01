;;; outline-jb-extras.el --- Extra commands & functions for outline/outshine-mode

;; Filename: outline-jb-extras.el
;; Description: Extra commands & functions for outline/outshine-mode
;; Author: Joe Bloggs <vapniks@yahoo.com>
;; Maintainer: Joe Bloggs <vapniks@yahoo.com>
;; Copyleft (Ↄ) 2026, Joe Bloggs, all rites reversed.
;; Created: 2026-03-24 22:30:59
;; Version: 0.1
;; Last-Updated: Wed Mar 25 00:53:04 2026
;;           By: Joe Bloggs
;;     Update #: 2
;; URL: https://github.com/vapniks/outline-jb-extras
;; Keywords: convenience
;; Compatibility: GNU Emacs 30.1
;; Package-Requires: ((outshine "20220326.540"))
;;
;; Features that might be required by this library:
;;
;; outshine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.
;; If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Commentary: 
;; 
;; Bitcoin donations gratefully accepted: 1ArFina3Mi8UDghjarGqATeBgXRDWrsmzo
;; 
;;; Installation
;; 
;; To install without using a package manager:
;; 
;;  - Put the library in a directory in the emacs load path, like ~/.emacs.d/
;;  - Add (require 'outline-jb-extras) in your ~/.emacs file
;;;;;;;;

;;; Commands:
;;
;; Below is a complete list of commands:
;;
;;  `outline-forward-up-heading'
;;    Move up ARG levels and then forward one heading.
;;    Keybinding: C-M-# C-S-<down>
;;  `outshine-toggle-speed-commands'
;;    Toggle the value of `outshine-use-speed-commands'.
;;    Keybinding: C-M-# C-S-s
;;  `outshine-toggle-speed-command-help'
;;    Toggle display of the Outshine speed-command help buffer.
;;    Keybinding: M-x outshine-toggle-speed-command-help
;;  `outshine-add-headers'
;;    Add `outshine-mode' compatible headers at locations in buffer matching regexps.
;;    Keybinding: M-x outshine-add-headers
;;
;;; Customizable Options:
;;
;; Below is a list of customizable options:
;;
;;  `outshine-user-headers'
;;    List of predefined header specifications for `outshine-add-headers'.
;;    default = nil

;;
;; All of the above can be customized by:
;;      M-x customize-group RET outline-jb-extras RET
;;

;;; Installation:
;;
;; Put outline-jb-extras.el in a directory in your load-path, e.g. ~/.emacs.d/
;; You can add a directory to your load-path with the following line in ~/.emacs
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;; where ~/elisp is the directory you want to add 
;; (you don't need to do this for ~/.emacs.d - it's added by default).
;;
;; Add the following to your ~/.emacs startup file.
;;
;; (require 'outline-jb-extras)

;;; History:

;;; Require
(require 'outshine)

;;; Code:

;;;###autoload
(defun outline-forward-up-heading (arg)
  "Move up ARG levels and then forward one heading."
  (interactive "p")
  (outline-up-heading arg)
  (org-forward-heading-same-level 1))
;;;###autoload
(defun outshine-toggle-speed-commands nil
  "Toggle the value of `outshine-use-speed-commands'."
  (interactive)
  (setq outshine-use-speed-commands
	(if outshine-use-speed-commands nil t))
  (message (format "Outshine speed commands are now %s"
		   (if outshine-use-speed-commands "activated" "deactivated"))))
;;;###autoload
(defun outshine-toggle-speed-command-help ()
  "Toggle display of the Outshine speed-command help buffer."
  (interactive)
  (let ((win (get-buffer-window "*Help*" 0)))
    (if (window-live-p win)
        (delete-window win)
      (outshine-speed-command-help))))
;;;###autoload
(defcustom outshine-user-headers nil
  "List of predefined header specifications for `outshine-add-headers'.
Each element has the form:

 (DESCRIPTION HEADERS)

DESCRIPTION is a string naming the header set.
HEADERS is a list of triplets of the form:

  (MATCH TITLE DEPTH)

MATCH is a regexp matching text before which a header should be inserted.
TITLE is the string used as the header title.
DEPTH is a positive integer specifying the depth of the header to create.

MATCH may contain regexp groups which can be referenced in TITLE."
  :group 'outshine
  :type '(repeat (list (string :tag "Description")
		       (repeat (list (regexp :tag "Match regexp")
				     (string :tag "Title")
				     (integer :tag "Depth"))))))
;;;###autoload
(defun outshine-add-headers (hdrs &optional query)
  "Add `outshine-mode' compatible headers at locations in buffer matching regexps.
When called interactively the user is prompted for a predefined header set in `outshine-user-headers',
or \"NEW\" to create a new set of HDRS, and QUERY is set to t.
Otherwise HDRS should be a list in the form described in `outshine-user-headers' (HEADERS),
and QUERY should be non-nil if the user is to be queried for each header insertion."
  (interactive (let* ((saved outshine-user-headers)
		      (choice (when saved (completing-read
					   "Choose saved header set or NEW: "
					   (append (mapcar #'car saved) '("NEW"))
					   nil t)))
		      hdrs)
		 (if (and choice (not (string= choice "NEW")))
		     (list (cadr (assoc choice saved)) t)
		   (list (let (hdrs regex title depth)
			   (while (not (string-empty-p
					(setq regex
					      ;;TODO: make the function for reading a regexp a user option so that
					      ;; something like visual-regexp.el or a function in regex-collection.el
					      ;; can be used if they want
					      (read-string
					       "Regexp matching line directly after header (empty to finish): "))))
			     (setq title (read-string "Header title (may contain references to groups): "))
			     (setq depth (read-number "Depth (positive integer): " nil t))
			     (push (list regex title depth) hdrs))
			   (when (and hdrs
				      (y-or-n-p "Save this triplet list in `outshine-user-headers'? "))
			     (let ((description (read-string "Description: ")))
			       (setq hdrs (reverse hdrs))
			       (customize-save-variable
				'outshine-user-headers
				(append outshine-user-headers
					(list (list description hdrs))))))
			   hdrs)
			 t))))
  (save-excursion
    (dolist (hdr hdrs)
      (cl-destructuring-bind (match title nstars) hdr
	(goto-char (point-max))
	(let ((repl (concat (string-trim-right comment-start) " "
			    (make-string nstars ?*)
			    " " title)))
	  (or (and (re-search-backward (replace-regexp-in-string "\\\\[0-9]" ".*" repl)
				       (point-min) t)
		   (forward-line 1)
		   (looking-at match)
		   (forward-line 1))
	      (goto-char (point-min)))
	  (funcall (if query 'query-replace-regexp 'replace-regexp)
		   match (concat repl "\n\\&"))))))
  (outshine-mode 1)
  (if (not (equal outline-heading-end-regexp "\n"))
      (warn "`outline-heading-end-regexp' is not equal to \"\\\\n\", this may cause problems"))
  (when (called-interactively-p 'any)
    (when (y-or-n-p "Add file local variable to start `outshine-mode' automatically when file is revisited?")
      (add-file-local-variable 'eval '(outshine-mode 1)))
    (goto-char (point-min))
    (outline-next-visible-heading 1)))

;; REMEMBER TODO ;;;###autoload's 


(provide 'outline-jb-extras)

;; (org-readme-sync)
;; (magit-push)

;;; outline-jb-extras.el ends here
