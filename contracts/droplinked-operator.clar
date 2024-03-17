(define-constant err-droplinked-only (err u100))
(define-constant err-publisher-only (err u101))
(define-constant err-producer-only (err u102))

(define-constant err-invalid-price (err u200))
(define-constant err-invalid-type (err u201))
(define-constant err-invalid-request-id (err u202))

(define-constant err-request-duplicate (err u300))
(define-constant err-request-accepted (err u301))

(define-data-var droplinked principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

(define-constant TYPE_DIGITAL 0x00)
(define-constant TYPE_POD 0x01)
(define-constant TYPE_PHYSICAL 0x02)

(define-constant STATUS_PENDING 0x00)
(define-constant STATUS_ACCEPTED 0x01)

(define-public 
  (set-droplinked
    (address principal)
  )
  (begin 
    (asserts! (is-eq (var-get droplinked) tx-sender) err-droplinked-only)
    (ok (var-set droplinked address))
  )
)

(define-public 
  (create-product
    (uri (string-ascii 256))
    (price uint)
    (commission uint)
    (amount uint)
    (type (buff 1))
    (recipient principal)
    (destination principal)
  )
  (let 
    (
      (product-id (try! (contract-call? .droplinked-token mint amount recipient uri)))
    )
    (asserts! (is-eq price u0) err-invalid-price)
    (asserts! 
      (or 
        (is-eq type TYPE_DIGITAL)
        (is-eq type TYPE_POD)
        (is-eq type TYPE_PHYSICAL)
      )
      err-invalid-type
    )
    (try! (contract-call? .droplinked-base insert-product product-id tx-sender price commission type destination))
    (ok product-id)
  )
)

(define-public 
  (create-request
    (product-id uint)
    (producer principal)
    (publisher principal)
  )
  (begin
    (asserts! (is-eq publisher tx-sender) err-publisher-only)
    (asserts! (is-eq (contract-call? .droplinked-base has-producer-requested-product? product-id producer publisher) false) err-request-duplicate)
    (let 
      (
        (request-id (try! (contract-call? .droplinked-base insert-request product-id producer publisher STATUS_PENDING)))
      )
      (try! (contract-call? .droplinked-base insert-publisher-request request-id publisher))
      (try! (contract-call? .droplinked-base insert-producer-request request-id producer))
      (try! (contract-call? .droplinked-base insert-is-requested product-id producer publisher))
      (ok request-id)
    )
  )
)

(define-public 
  (cancel-request
    (request-id uint)
    (publisher principal)
  )
  (let 
    (
      (request (unwrap! (contract-call? .droplinked-base get-request? request-id) err-invalid-request-id))
      (product-id (get product-id request))
      (producer (get producer request))
    )
    (asserts! (is-eq publisher tx-sender) err-publisher-only)
    (asserts! (is-eq publisher (get publisher request)) err-publisher-only)
    (asserts! (is-eq (get status request) STATUS_PENDING) err-request-accepted)
    (try! (contract-call? .droplinked-base remove-producer-request request-id producer))
    (try! (contract-call? .droplinked-base remove-publisher-request request-id publisher))
    (try! (contract-call? .droplinked-base remove-is-requested product-id producer publisher))
    (ok true)
  )
)

(define-public 
  (accept-request
    (request-id uint)
    (producer principal)
  )
  (let 
    (
      (request (unwrap! (contract-call? .droplinked-base get-request? request-id) err-invalid-request-id))
    )
    (asserts! (is-eq producer tx-sender) err-producer-only)
    (asserts! (is-eq producer (get producer request)) err-producer-only)
    (try! (contract-call? .droplinked-base update-request-status request-id STATUS_ACCEPTED))
    (ok true)
  )
)