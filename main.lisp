(in-package :github-install)

(defvar *github-install-path-prefix* "github-install/")
(defvar *github-install-version-dir* 'version-dir)
(defvar *github-install-homepath*
  #+quicklisp (first (last ql:*local-project-directories*))
  #-quicklisp (user-homedir-pathname))

(defun version-dir ()
  (apply #'format nil "~A-~A/"
         (nreverse (subseq (multiple-value-list (decode-universal-time (get-universal-time))) 4 6))))

(defun install-dir ()
  (merge-pathnames
   (funcall *github-install-version-dir*)
   (merge-pathnames *github-install-path-prefix* 
                    *github-install-homepath*)))


(defun extract (path)
  #+quicklisp
  (let ((tarpath (make-pathname :type "tar" :name "tmp" :defaults path)))
    (ql-gunzipper:gunzip path  tarpath)
    (ql-minitar:unpack-tarball tarpath 
                               :directory 
                               (make-pathname :type nil :name nil :defaults path)))
  #-quicklisp
  (format t "Archive ~s is not extracted. quicklisp are required to do so." path))

(defun github-download (user-name name branch)
  (let (path)
    (multiple-value-bind (input code params)
        (drakma:http-request
         (format nil 
                 "http://github.com/~A/~A/tarball/~A"
                 user-name name branch)
         :want-stream t :force-binary t)
      (when (= code 200)
        (with-open-file (output 
                         (setf path (ensure-directories-exist
                                     (merge-pathnames 
                                      (second (cl-ppcre:split "=" (cdr (assoc :content-disposition params))))
                                      (install-dir))))
                         :direction :output 
                         :element-type '(unsigned-byte 8)
                         :if-exists :supersede)
          (alexandria:copy-stream input output))))
    path))

(defun github-install (username name &key (branch "master") (extract t))
  (let ((path (github-download username name branch)))
    (when (and extract path)
      (extract path))))
