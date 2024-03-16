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

(define-map is-requested 
  { 
    product-id: uint,
    producer: principal,
    publisher: principal
  }
  bool
)

(define-map producers-requests 
  {
    request-id: uint,
    producer: principal
  }
  bool
)

(define-map publishers-requests 
  {
    request-id: uint,
    publisher: principal
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

(define-data-var last-request-id uint u0)

(define-public
  (insert-product
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

;; creates a new request and returns generated request-id
(define-public 
  (insert-request
    (product-id uint)
    (producer principal)
    (publisher principal)
  )
  (let 
    (
      (request-id (+ (var-get last-request-id) u1))
    )
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (map-insert requests 
      request-id
      {
        product-id: product-id,
        producer: producer,
        publisher: publisher
      }
    )
    (var-set last-request-id request-id)
    (ok request-id)
  )
)

(define-public 
  (insert-publisher-request
    (request-id uint)
    (publisher principal)
  )
  (begin 
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (map-insert publishers-requests 
      {
        request-id: request-id,
        publisher: publisher
      }
     true
    )
    (ok true)
  )
)

(define-public 
  (insert-producer-request
    (request-id uint)
    (producer principal)
  )
  (begin 
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (map-insert producers-requests 
      {
        request-id: request-id,
        producer: producer
      }
     true
    )
    (ok true)
  )
)

(define-public 
  (insert-is-requested
    (product-id uint)
    (producer principal)
    (publisher principal)
  )
  (begin 
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (ok
      (map-insert is-requested 
        {
          product-id: product-id,
          producer: producer,
          publisher: publisher
        }
        true
      )
    )
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
    (publisher principal)
  )
  (is-some 
    (map-get? is-requested  
      {
        product-id: product-id,
        producer: producer,
        publisher: publisher
      }
    )
  )
)
