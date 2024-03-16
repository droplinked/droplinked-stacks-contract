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
