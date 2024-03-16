(define-constant err-droplinked-operator-only (err u100))

(define-constant err-product-exists (err u200))

;; maps request-id to product details (product-id, producer, publisher)
(define-map requests uint 
  {
    product-id: uint,
    producer: principal,
    publisher: principal
  }
)

(define-map issuers uint 
  {
    issuer: principal,
    royalty: uint
  }
)

(define-map prices
  {
    product-id: uint,
    owner: principal
  }
  uint
)

(define-map commissions
  {
    product-id: uint,
    owner: principal
  }
  uint
)

(define-map types uint (buff 1))

(define-public
  (insert-product-information
    (product-id uint)
    (owner principal)
    (price uint)
    (commission uint)
    (type (buff 1))
    (destination principal)
  )
  (begin 
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (asserts! (map-insert prices { product-id: product-id, owner: owner } price) err-product-exists)
    (asserts! (map-insert commissions { product-id: product-id, owner: owner } commission) err-product-exists)
    (asserts! (map-insert types product-id type) err-product-exists)
    (ok true)
  )
)

(define-read-only
  (get-price
    (product-id uint)
    (owner principal)
  )
  (map-get? prices 
    {
      product-id: product-id,
      owner: owner
    }
  )
)