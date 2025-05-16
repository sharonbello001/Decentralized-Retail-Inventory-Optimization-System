;; Product Registration Contract
;; This contract records merchandise details

(define-data-var admin principal tx-sender)

;; Product data structure
(define-map products
  { product-id: uint }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    sku: (string-utf8 50),
    category: (string-utf8 50),
    manufacturer: principal,
    created-at: uint
  }
)

;; Product counter
(define-data-var product-counter uint u0)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Register a new product
(define-public (register-product
  (name (string-utf8 100))
  (description (string-utf8 500))
  (sku (string-utf8 50))
  (category (string-utf8 50))
)
  (let
    (
      (product-id (+ (var-get product-counter) u1))
    )
    (asserts! (> (len name) u0) (err u1)) ;; Name cannot be empty
    (asserts! (> (len sku) u0) (err u2)) ;; SKU cannot be empty

    ;; Update product counter and add product to map
    (var-set product-counter product-id)
    (map-set products
      { product-id: product-id }
      {
        name: name,
        description: description,
        sku: sku,
        category: category,
        manufacturer: tx-sender,
        created-at: block-height
      }
    )
    (ok product-id)
  )
)

;; Update product details (only manufacturer can update)
(define-public (update-product
  (product-id uint)
  (name (string-utf8 100))
  (description (string-utf8 500))
  (category (string-utf8 50))
)
  (let
    (
      (product (unwrap! (map-get? products { product-id: product-id }) (err u3)))
    )
    (asserts! (is-eq (get manufacturer product) tx-sender) (err u4)) ;; Only manufacturer can update

    ;; Update product details
    (map-set products
      { product-id: product-id }
      (merge product {
        name: name,
        description: description,
        category: category
      })
    )
    (ok true)
  )
)

;; Get product details
(define-read-only (get-product (product-id uint))
  (map-get? products { product-id: product-id })
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u5)) ;; Only current admin can transfer admin rights
    (var-set admin new-admin)
    (ok true)
  )
)
