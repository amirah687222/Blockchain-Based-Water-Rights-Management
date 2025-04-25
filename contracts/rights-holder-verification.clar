;; Rights Holder Verification Contract
;; Purpose: Validates legitimate water users

(define-data-var admin principal tx-sender)

;; Data map to store verified rights holders
(define-map rights-holders principal
  {
    verified: bool,
    registration-date: uint,
    license-id: (string-utf8 50)
  }
)

;; Register a new rights holder (only admin)
(define-public (register-rights-holder
                 (holder principal)
                 (license-id (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (not (is-some (map-get? rights-holders holder))) (err u101))
    (ok (map-set rights-holders holder
      {
        verified: true,
        registration-date: block-height,
        license-id: license-id
      }))
  )
)

;; Remove a rights holder (only admin)
(define-public (revoke-rights-holder (holder principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-some (map-get? rights-holders holder)) (err u102))
    (ok (map-delete rights-holders holder))
  )
)

;; Check if a principal is a verified rights holder
(define-read-only (is-verified-holder (holder principal))
  (match (map-get? rights-holders holder)
    holder-data (get verified holder-data)
    false
  )
)

;; Set a new admin (only current admin)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)

;; Get rights holder information
(define-read-only (get-holder-info (holder principal))
  (map-get? rights-holders holder)
)

;; Error codes:
;; u100 - Not authorized
;; u101 - Rights holder already registered
;; u102 - Rights holder not found
