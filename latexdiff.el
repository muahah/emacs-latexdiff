;;;;;; todo ;;;;;;
;; add check to test if latexdiff is installed
;; add nice colors
;; add ergonomy !



(defface latexdiff-date-face
  '((t (:inherit default :foreground "red")))
  "Face for the date"
  :group 'latexdiff)

(defface latexdiff-author-face
  '((t (:inherit default :foreground "green")))
  "Face for the author"
  :group 'latexdiff)

(defface latexdiff-message-face
  '((t (:inherit default :foreground "white")))
  "Face for the message"
  :group 'latexdiff)

(defface latexdiff-ref-labels-face
  '((t (:inherit default :foreground "orange")))
  "Face for the ref-labels"
  :group 'latexdiff)

(defun latexdiff--compile-diff (&optional REV1 REV2)
  "Use latexdiff to compile a pdf file of the
difference between REV1 and REV2"
  (let ((file (TeX-master-file nil nil t))
	(diff-file (format "%s-diff%s-%s" (TeX-master-file nil nil t) REV1 REV2)))
    (message "[%s.tex] Generating latex diff between %s and %s" file REV1 REV2)
    (call-process "/bin/bash" nil 0 nil "-c"
		  (format "yes X | latexdiff-vc --force -r %s -r %s %s.tex --pdf > latexdiff.log ;
                           GLOBIGNORE='*.pdf' ;
                           rm -r %s* ;
                           rm -r %s-oldtmp* ;
                           GLOBIGNORE='' ;
                           okular %s.pdf "
			  REV1 REV2 file diff-file file diff-file))))

(defun latexdiff--compile-diff-with-current (REV)
  "Use latexdiff to compile a pdf file of the
difference between the current state and REV"
  (let ((file (TeX-master-file nil nil t))
	(diff-file (format "%s-diff%s" (TeX-master-file nil nil t) REV)))
    (message "[%s.tex] Generating latex diff with %s" file REV)
    (call-process "/bin/bash" nil 0 nil "-c"
		  (format "yes X | latexdiff-vc --force -r %s %s.tex --pdf > latexdiff.log ;
                           GLOBIGNORE='*.pdf' ;
                           rm -r %s* ;
                           rm -r %s-oldtmp* ;
                           GLOBIGNORE='' ;
                           okular %s.pdf "
			  REV file diff-file file diff-file))))

(defun latexdiff--clean ()
  "Remove all file generated by latexdiff"
  (interactive)
  (let ((file (TeX-master-file nil nil t)))
    (call-process "/bin/bash" nil 0 nil "-c"
		  (format "rm -f %s-diff* ;
                           rm -f %s-oldtmp* ;
                           rm -f latexdiff.log"
			  file file))))

(defun latexdiff--get-commits-infos ()
  "Return a list with all commits informations"
  (interactive)
  (let ((infos nil))
    (with-temp-buffer
      (vc-git-command t nil nil "log" "--format=%h---%cr---%cn---%s---%d" "--abbrev-commit" "--date=short")
      (goto-char (point-min))
      (while (re-search-forward "^.+$" nil t)
	(push (split-string (match-string 0) "---") infos)))
    infos))

(defun latexdiff--get-commits-description ()
  "Return a list of commits description strings
to use with helm"
  (interactive)
  (let ((descriptions ())
	(infos (latexdiff--get-commits-infos))
	(tmp-desc nil))
    (dolist (tmp-desc infos)
      (pop tmp-desc)
      (push (string-join
	     (list
	      (propertize (nth 1 tmp-desc) 'face 'latexdiff-author-face)
	      (propertize (nth 0 tmp-desc) 'face 'latexdiff-date-face)
	      (propertize (nth 2 tmp-desc) 'face 'latexdiff-message-face)
	      (propertize (nth 3 tmp-desc) 'face 'latexdiff-ref-labels-face))
	     " ")
	    descriptions)
      )
    descriptions))

(defun latexdiff--get-commits-hashes ()
  "Return the list of commits hashes"
  (interactive)
  (let ((hashes ())
	(infos (latexdiff--get-commits-infos))
	(tmp-desc nil))
    (dolist (tmp-desc infos)
      (push (pop tmp-desc) hashes)
      )
      hashes))

(defun latexdiff--update-commits ()
  "Update the list of commits
to use with helm"
  (interactive)
  (let ((descr (latexdiff--get-commits-description))
	(hash (latexdiff--get-commits-hashes))
	(list ()))
    (while (not (equal (length descr) 0))
      (setq list (cons (cons (pop descr) (pop hash)) list)))
    (reverse list)))

(defvar helm-source-latexdiff-choose-commit
  (helm-build-sync-source "Latexdiff choose commit"
    ;; :init (lambda () (latexdiff--update-commits))
    :candidates 'latexdiff--update-commits
    :fuzzy-match helm-projectile-fuzzy-match
    ;; :keymap helm-latexdiff-commit-map
    :mode-line helm-read-file-name-mode-line-string
    :action '(("Choose this commit" . latexdiff--compile-diff-with-current))
    )
  "Helm source for modified projectile projects.")

(defvar helm-source-latexdiff-choose-commit-range
  (helm-build-sync-source "Latexdiff choose commit"
    :candidates 'latexdiff--update-commits
    :fuzzy-match helm-projectile-fuzzy-match
    :mode-line helm-read-file-name-mode-line-string
    :action '(("Choose these commits" . latexdiff--compile-diff))
    )
  "Helm source for modified projectile projects.")

(defun helm-latexdiff ()
  (interactive)
  (helm :sources 'helm-source-latexdiff-choose-commit
	:buffer "*helm-latexdiff*"
	:nomark t
	:prompt "Choose a commit: "))

(defun helm-latexdiff-range ()
  (interactive)
  (let ((commits (latexdiff--update-commits)))
    (let ((rev1 (helm-comp-read "First commit: " commits))
	  (rev2 (helm-comp-read "Second commit: " commits)))
    (latexdiff--compile-diff rev1 rev2)
  )))

(evil-leader/set-key-for-mode 'latex-mode "ed" 'helm-latexdiff)
(evil-leader/set-key-for-mode 'latex-mode "eD" 'helm-latexdiff-range)
(evil-leader/set-key-for-mode 'latex-mode "ec" 'latexdiff--clean)
