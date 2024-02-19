(fn message [role content]
  {: content : role})

(fn system [content]
  (message :system content))

(fn user [content]
  (message :user content))

(fn assistant [content]
  (message :assistant content))  

{: system
 : user
 : assistant}
