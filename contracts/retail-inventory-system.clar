;; Store Verification Contract
;; This contract validates retail locations in the system

(define-data-var admin principal tx-sender)

;; Store data structure
(define-map stores
  { store-id: uint }
  {
    name: (string-utf8 100),
    location: (string-utf8 100),
    is-verified: bool,
    owner: principal
  }
)

;; Store counter
(define-data-var store-counter uint u0)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Register a new store
(define-public (register-store (name (string-utf8 100)) (location (string-utf8 100)))
  (let
    (
      (store-id (+ (var-get store-counter) u1))
    )
    (asserts! (> (len name) u0) (err u1)) ;; Name cannot be empty
    (asserts! (> (len location) u0) (err u2)) ;; Location cannot be empty

    ;; Update store counter and add store to map
    (var-set store-counter store-id)
    (map-set stores
      { store-id: store-id }
      {
        name: name,
        location: location,
        is-verified: false,
        owner: tx-sender
      }
    )
    (ok store-id)
  )
)

;; Verify a store (admin only)
(define-public (verify-store (store-id uint))
  (let
    (
      (store (unwrap! (map-get? stores { store-id: store-id }) (err u3)))
    )
    (asserts! (is-admin) (err u4)) ;; Only admin can verify stores

    ;; Update store verification status
    (map-set stores
      { store-id: store-id }
      (merge store { is-verified: true })
    )
    (ok true)
  )
)

;; Get store details
(define-read-only (get-store (store-id uint))
  (map-get? stores { store-id: store-id })
)

;; Check if store is verified
(define-read-only (is-store-verified (store-id uint))
  (default-to false (get is-verified (map-get? stores { store-id: store-id })))
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u5)) ;; Only current admin can transfer admin rights
    (var-set admin new-admin)
    (ok true)
  )
)
