;; extends
(
  (pair
    key: (property_identifier) @key (#eq? @key "template")
    value: (template_string) @injection.content
  )
  (#set! injection.language "html")
)
