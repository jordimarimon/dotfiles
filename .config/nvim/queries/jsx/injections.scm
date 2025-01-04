; extends

(jsx_element
    open_tag: (jsx_opening_element
        name: (identifier) @tag_script (#eq? @tag_script "script"))
    (jsx_expression
        (template_string
            (string_fragment) @injection.content
                (#set! injection.language "javascript"))))

(jsx_element
    open_tag: (jsx_opening_element
        name: (identifier) @tag_script (#eq? @tag_script "style"))
    (jsx_expression
        (template_string
            (string_fragment) @injection.content
                (#set! injection.language "css"))))
