;; extends
;; Angular Component template injection
(
  (pair
    key: (property_identifier) @key (#eq? @key "template")
    value: (template_string) @injection.content
  )
  (#set! injection.language "html")
)

;; Angular Component styles injection
(
  (pair
    key: (property_identifier) @key (#eq? @key "styles")
    value: (array
      (template_string) @injection.content
    )
  )
  (#set! injection.language "css")
)

;; Single style string injection
(
  (pair
    key: (property_identifier) @key (#eq? @key "styles")
    value: (template_string) @injection.content
  )
  (#set! injection.language "css")
)

;; styleUrls - inline CSS/SCSS in string literals
(
  (pair
    key: (property_identifier) @key (#eq? @key "styleUrls")
    value: (array
      (string) @injection.content
    )
  )
  (#set! injection.language "css")
)

;; HTML template strings in functions (for inline templates)
(
  (call_expression
    function: (identifier) @func_name (#match? @func_name "^(html|template)$")
    arguments: (arguments (template_string) @injection.content)
  )
  (#set! injection.language "html")
)

;; CSS template strings in functions
(
  (call_expression
    function: (identifier) @func_name (#match? @func_name "^(css|style)$")
    arguments: (arguments (template_string) @injection.content)
  )
  (#set! injection.language "css")
)
