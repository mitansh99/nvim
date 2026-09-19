;; extends
;; ---------------------------------------------------------------------------
;;  Tell JSX tags apart.
;;
;;  The stock grammar captures every element name as plain @tag, so in a React
;;  Native file <ThemedView>, <ThemedText> and <Collapsible> all render in the
;;  same colour as `return` and `const`. These rules split them into:
;;
;;    @tag.component   custom components   <ThemedView>   (capitalised)
;;    @tag.builtin     host elements       <div> <span>   (lowercase)
;;    @tag.member      member expressions  <Animated.View>
;;
;;  and give every CLOSING tag a dimmed variant, so the eye follows the
;;  opening tags and the </...> noise recedes.
;; ---------------------------------------------------------------------------

; ---- custom components: capitalised ----------------------------------------
((jsx_opening_element name: (identifier) @tag.component)
 (#lua-match? @tag.component "^%u"))

((jsx_self_closing_element name: (identifier) @tag.component)
 (#lua-match? @tag.component "^%u"))

((jsx_closing_element name: (identifier) @tag.component.closing)
 (#lua-match? @tag.component.closing "^%u"))

; ---- host elements: lowercase ----------------------------------------------
((jsx_opening_element name: (identifier) @tag.builtin)
 (#lua-match? @tag.builtin "^%l"))

((jsx_self_closing_element name: (identifier) @tag.builtin)
 (#lua-match? @tag.builtin "^%l"))

((jsx_closing_element name: (identifier) @tag.builtin.closing)
 (#lua-match? @tag.builtin.closing "^%l"))

; ---- member expressions: <Animated.View> -----------------------------------
; The object/property nodes are targeted directly. Capturing the whole
; member_expression loses to the base query, which captures the inner
; identifier and is the narrower match.
(jsx_opening_element
  name: (member_expression
          object: (identifier) @tag.member
          property: (property_identifier) @tag.member))

(jsx_self_closing_element
  name: (member_expression
          object: (identifier) @tag.member
          property: (property_identifier) @tag.member))

(jsx_closing_element
  name: (member_expression
          object: (identifier) @tag.member.closing
          property: (property_identifier) @tag.member.closing))
