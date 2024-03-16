(define-constant err-droplinked-only (err u100))

(define-constant err-invalid-price (err u200))
(define-constant err-invalid-type (err u201))

(define-data-var droplinked principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

(define-constant TYPE_DIGITAL 0x00)
(define-constant TYPE_POD 0x01)
(define-constant TYPE_PHYSICAL 0x02)

;; allows the current droplinked owner to update the droplinked address
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
    (try! (contract-call? .droplinked-base insert-product-information product-id tx-sender price commission type destination))
    (ok product-id)
  )
)
