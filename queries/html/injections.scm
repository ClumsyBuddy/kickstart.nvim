;; extends
;; CSS injection for class attributes (Tailwind CSS support)
(
  (attribute
    (attribute_name) @attr_name (#eq? @attr_name "class")
    (quoted_attribute_value (attribute_value) @injection.content)
  )
  (#set! injection.language "css")
)

;; CSS injection for Angular ngClass
(
  (attribute
    (attribute_name) @attr_name (#match? @attr_name "^(\\[class\\]|ngClass)$")
    (quoted_attribute_value (attribute_value) @injection.content)
  )
  (#set! injection.language "css")
)

;; CSS injection for style attributes
(
  (attribute
    (attribute_name) @attr_name (#eq? @attr_name "style")
    (quoted_attribute_value (attribute_value) @injection.content)
  )
  (#set! injection.language "css")
)

;; Angular style binding
(
  (attribute
    (attribute_name) @attr_name (#match? @attr_name "^\\[style")
    (quoted_attribute_value (attribute_value) @injection.content)
  )
  (#set! injection.language "css")
)

;; TypeScript injection for Angular event handlers and property bindings
(
  (attribute
    (attribute_name) @attr_name (#match? @attr_name "^(\\(.*\\)|\\[.*\\])$")
    (quoted_attribute_value (attribute_value) @injection.content)
  )
  (#set! injection.language "typescript")
)