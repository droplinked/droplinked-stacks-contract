(define-constant err-droplinked-only (err u100))

(define-data-var droplinked principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

(define-public 
  (set-droplinked
    (address principal)
  )
  (begin 
    (asserts! (is-eq (var-get droplinked) tx-sender) err-droplinked-only)
    (ok (var-set droplinked address))
  )
)