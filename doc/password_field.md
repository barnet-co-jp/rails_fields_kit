# Password Field Native Wrapper

`rfk_password_field` renders a Rails `password_field` through the same native wrapper lane as `rfk_text_field`, `rfk_email_field`, and the other native helpers.

Use it when the host app wants Rails Fields Kit's wrapper, label, hint, error, affix, and accessibility wiring around an ordinary password input.

```erb
<%= f.rfk_password_field :password,
  wrapper: true,
  label: "Password",
  hint: "Use your account password",
  autocomplete: "current-password" %>
```

## Responsibility Boundary

Rails Fields Kit keeps this helper intentionally thin:

- It renders a native `type="password"` input.
- It reuses the existing native wrapper options such as `wrapper:`, `label:`, `hint:`, `html:`, `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, `suffix_html:`, and `accessibility:`.
- It passes ordinary Rails/native field options through to the password input.
- It does not add a password visibility toggle.
- It does not add a password strength meter.
- It does not decide credential policy, password validation rules, or autocomplete policy.
- It does not change authentication workflow or credential storage.

When a host app needs a visibility toggle, strength meter, password manager guidance, or credential-specific validation copy, keep that behavior in host-app code around the rendered Rails Fields Kit field.
