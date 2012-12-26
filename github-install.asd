(asdf:defsystem #:github-install
  :serial t
  :version "2012.12.27"
  :license "MIT"
  :description "download archive from github and extract it if possible"
  :components ((:file "package")
	       (:file "main"))
  :depends-on (:drakma 
               :cl-ppcre))