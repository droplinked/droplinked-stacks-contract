(define-constant err-droplinked-operator-only (err u100))

(define-map requests uint 
  {
    product-id: uint,
    producer: principal,
    publisher: principal,
    status: (buff 1)
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

(define-map beneficiaries-links uint uint)

(define-map beneficiaries-lists uint
  {
    is-percentage: bool,
    value: uint,
    address: principal,
    next: (optional uint)
  }
)

(define-map destinations 
  {
    product-id: uint,
    producer: principal
  }
  principal
)

(define-data-var last-request-id uint u0)

(define-data-var last-beneficiary-id uint u0)

(define-public
  (insert-product
    (product-id uint)
    (owner principal)
    (price uint)
    (commission uint)
    (beneficiaries (list 16 
      {
        is-percentage: bool,
        value: uint,
        address: principal,
      }
    ))
    (type (buff 1))
    (destination principal)
  )
  (begin
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (map-insert prices { product-id: product-id, owner: owner } price)
    (map-insert commissions { product-id: product-id, owner: owner } commission)
    (map-insert types product-id type)
    (map-insert destinations 
      {
        product-id: product-id,
        producer: owner
      }
      destination
    )
    (if (>= (len beneficiaries) u1)
      (let 
        (
          (beneficiary-link (+ (var-get last-beneficiary-id) u1))
        )
        (map-insert beneficiaries-links product-id beneficiary-link)
        (fold insert-beneficiary-iter beneficiaries 
          { 
            length: (len beneficiaries),
            index: u0, 
            benificiary-id: beneficiary-link
          }
        )
        (ok true)
      )
      (ok true)
    )
  )
)

(define-public 
  (insert-request
    (product-id uint)
    (producer principal)
    (publisher principal)
    (status (buff 1))
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
        publisher: publisher,
        status: status
      }
    )
    (var-set last-request-id request-id)
    (ok request-id)
  )
)

(define-public 
  (remove-request
    (request-id uint)
  )
  (begin
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (ok (map-delete requests request-id))
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
  (update-request-status
    (request-id uint)
    (status (buff 1))
  )
  (let 
    (
      (request (unwrap-panic (map-get? requests request-id)))
    )
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (ok 
      (map-set requests request-id 
        (merge 
          {
            product-id: (get product-id request),
            producer: (get producer request),
            publisher: (get publisher request)
          }
          {
            status: status
          }
        )
      )
    )
  )
)

(define-public 
  (remove-publisher-request
    (request-id uint)
    (publisher principal)
  )
  (begin 
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (ok 
      (map-delete publishers-requests 
        {
          request-id: request-id,
          publisher: publisher
        }
      )
    )
  )
)

(define-public 
  (remove-producer-request
    (request-id uint)
    (producer principal)
  )
  (begin 
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (ok 
      (map-delete producers-requests 
        {
          request-id: request-id,
          producer: producer
        }
      )
    )
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

(define-public 
  (remove-is-requested
    (product-id uint)
    (producer principal)
    (publisher principal)
  )
  (begin 
    (asserts! (is-eq contract-caller .droplinked-operator) err-droplinked-operator-only)
    (ok
      (map-delete is-requested 
        {
          product-id: product-id,
          producer: producer,
          publisher: publisher
        }
      )
    )
  )
)

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

(define-read-only 
  (get-commission?
    (product-id uint)
    (owner principal)
  )
  (map-get? commissions 
    {
      product-id: product-id,
      owner: owner
    }
  )
)


(define-read-only 
  (get-type?
    (product-id uint)
  )
  (map-get? types product-id)
)

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

(define-read-only 
  (get-request?
    (request-id uint)
  )
  (map-get? requests request-id)
)

(define-private 
  (insert-beneficiary-iter
    (beneficiary 
      {
        is-percentage: bool,
        value: uint,
        address: principal,
      }
    )
    (previous-result 
      { 
        length: uint,
        index: uint,
        benificiary-id: uint
      }
    )
  )
  (let 
    (
      (length (get length previous-result))
      (index (get index previous-result))
      (benificiary-id (get benificiary-id previous-result))
    )
    (if (is-eq index (- length u1)) 
      (begin 
        (map-insert beneficiaries-lists benificiary-id (merge beneficiary { next: none }))
        (var-set last-beneficiary-id benificiary-id)
        { length: length, index: index, benificiary-id: benificiary-id }
      )
      (let 
        (
          (next-benificiary-id (+ benificiary-id u1))
        )
        (map-insert beneficiaries-lists benificiary-id (merge beneficiary { next: (some next-benificiary-id) }))
        { length: length, index: (+ index u1), benificiary-id: next-benificiary-id }
      )
    )
  )
)