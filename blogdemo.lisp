;;;; blogdemo.lisp

(in-package #:blogdemo)

;;; "blogdemo" goes here. Hacks and glory await!

(define-route home ("")
  (list :title "Blogdemo"
        :body (mapcar #'render-post *posts*)))

(define-route post ("post/:id")
  (:sift-variables (id #'validate-post-id))
  (let ((post (elt *posts* id)))
    (list :title (getf post :title)
          :body (render-post post))))

(define-route author ("author/:id")
  (:sift-variables (id #'validate-author-id))
  (let ((posts (loop for post in *posts*
                if (string= id (getf post :author-id))
                collect post)))
    (list :title (format nil "Posts by ~a" (getf (first posts) :author))
          :body  (mapcar #'render-post posts))))

(define-route login ("login")
  (list :title "Log in"
        :body (login-form)))

(define-route login/post ("login" :method :post)
  (if (and (string= "user" (hunchentoot:post-parameter "username"))
           (string= "pass" (hunchentoot:post-parameter "password")))
      (progn
        (hunchentoot:start-session)
        (setf (hunchentoot:session-value :username) "user")
        (redirect 'home))
      (redirect 'login)))

(define-route logout ("logout")
  (setf (hunchentoot:session-value :username) nil)
  (redirect 'home))

(define-route add ("add")
  (:requirement #'logged-on-p)
  (list :title "Add a blog post"
        :body (add-post-form)))

(define-route add/post ("add" :method :post)
  (let ((author (hunchentoot:post-parameter "author"))
    (title  (hunchentoot:post-parameter "title"))
    (content (hunchentoot:post-parameter "content")))
    (push (list :author author
                :author-id (slug author)
                :title title
                :content content)
           *posts*)
    (redirect 'home)))

