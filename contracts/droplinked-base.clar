(define-constant err-droplinked-operator-only (err u100))

(define-constant err-product-exists (err u200))

;; maps (request-id) to request details (product-id, producer, publisher)
(define-map requests uint 
  {
    product-id: uint,
    producer: principal,
    publisher: principal
  }
)

(define-map producers-requests 
  {
    product-id: uint,
    producer: principal
  }
  bool
)

;; maps (product-id, owner) pairs to product prices
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

;; maps (product-id) to product type
;; 0x00 is digital product
;; 0x01 is pod product
;; 0x02 is physical product
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

;; returns product price for given (product-id, owner) pair
;; returns an optional(uint) containing the price if found, otherwise returns none
(define-read-only
  (get-price?
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
;; returns true if the producer has requested the product, otherwise returns false
(define-read-only 
  (has-producer-requested-product?
    (product-id uint)
    (producer principal)
  )
  (default-to false 
    (map-get? producers-requests 
      {
        product-id: product-id,
        producer: producer
      }
    )
  )
)