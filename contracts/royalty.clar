;; Royalty Contract
;; Handles royalty payments

(define-data-var last-id uint u0)

(define-map payments
  { id: uint }
  {
    license-id: uint,
    amount: uint,
    payer: principal,
    payee: principal
  }
)

;; Local copy of licenses map for reference
(define-map licenses
  { id: uint }
  {
    work-id: uint,
    licensor: principal,
    licensee: principal,
    active: bool,
    rate: uint
  }
)

(define-read-only (get-payment (id uint))
  (map-get? payments { id: id })
)

(define-read-only (get-last-id)
  (var-get last-id)
)

;; Function to register license data locally
(define-public (register-license-data (id uint) (work-id uint) (licensor principal) (licensee principal) (active bool) (rate uint))
  (begin
    (map-set licenses
      { id: id }
      {
        work-id: work-id,
        licensor: licensor,
        licensee: licensee,
        active: active,
        rate: rate
      }
    )
    (ok true)
  )
)

(define-public (make-payment (license-id uint) (amount uint))
  (let
    ((license (map-get? licenses { id: license-id }))
     (new-id (+ (var-get last-id) u1)))

    (asserts! (is-some license) (err u404))
    (asserts! (get active (unwrap! license (err u404))) (err u403))
    (asserts! (> amount u0) (err u400))

    (try! (stx-transfer? amount tx-sender (get licensor (unwrap! license (err u404)))))

    (var-set last-id new-id)

    (map-set payments
      { id: new-id }
      {
        license-id: license-id,
        amount: amount,
        payer: tx-sender,
        payee: (get licensor (unwrap! license (err u404)))
      }
    )

    (ok new-id)
  )
)
