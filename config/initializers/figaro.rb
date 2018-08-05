# frozen_string_literal: true

Figaro.require_keys(
  "COOKIE_STORE_KEY",
  "DEVISE_PEPPER",
  "DEVISE_SECRET_KEY",
  "SECRET_KEY_BASE"
)
