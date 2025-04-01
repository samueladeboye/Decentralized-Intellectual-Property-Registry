;; Licensing Contract
;; Manages licenses for works

(define-data-var last-id uint u0)

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

;; Local copy of owners map for reference
(define-map owners
  { work-id: uint }
  { owner: principal }
)

(define-read-only (get-license (id uint))
  (map-get? licenses { id: id })
)

(define-read-only (get-last-id)
  (var-get last-id)
)

;; Function to register owner data locally
(define-public (register-owner-data (work-id uint) (owner principal))
  (begin
    (map-set owners
      { work-id: work-id }
      { owner: owner }
    )
    (ok true)
  )
)

(define-public (create-license (work-id uint) (licensee principal) (rate uint))
  (let
    ((owner-data (map-get? owners { work-id: work-id }))
     (new-id (+ (var-get last-id) u1)))

    (asserts! (is-some owner-data) (err u404))
    (asserts! (is-eq tx-sender (get owner (unwrap! owner-data (err u404)))) (err u403))

    (var-set last-id new-id)

    (map-set licenses
      { id: new-id }
      {
        work-id: work-id,
        licensor: tx-sender,
        licensee: licensee,
        active: true,
        rate: rate
      }
    )

    (ok new-id)
  )
)

(define-public (revoke-license (id uint))
  (let
    ((license (map-get? licenses { id: id })))

    (asserts! (is-some license) (err u404))
    (asserts! (is-eq tx-sender (get licensor (unwrap! license (err u404)))) (err u403))

    (map-set licenses
      { id: id }
      (merge (unwrap! license (err u404)) { active: false })
    )

    (ok true)
  )
)
