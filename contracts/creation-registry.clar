;; Creation Registry Contract
;; Simple registry for creative works

(define-data-var last-id uint u0)

(define-map works
  { id: uint }
  {
    creator: principal,
    title: (string-ascii 64),
    hash: (buff 32)
  }
)

(define-read-only (get-work (id uint))
  (map-get? works { id: id })
)

(define-read-only (get-last-id)
  (var-get last-id)
)

(define-public (register-work (title (string-ascii 64)) (hash (buff 32)))
  (let
    ((new-id (+ (var-get last-id) u1)))

    (var-set last-id new-id)

    (map-set works
      { id: new-id }
      {
        creator: tx-sender,
        title: title,
        hash: hash
      }
    )

    (ok new-id)
  )
)
