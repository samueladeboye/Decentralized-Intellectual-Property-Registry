;; Ownership Contract
;; Tracks ownership of registered works

(define-map owners
  { work-id: uint }
  { owner: principal }
)

(define-read-only (get-owner (work-id uint))
  (map-get? owners { work-id: work-id })
)

(define-public (claim-ownership (work-id uint))
  (begin
    ;; Get the work directly without contract call
    (let ((work-data (get-work-data work-id)))
      (asserts! (is-some work-data) (err u404))
      (asserts! (is-eq tx-sender (get creator (unwrap! work-data (err u404)))) (err u403))
      (asserts! (is-none (map-get? owners { work-id: work-id })) (err u409))

      (map-set owners
        { work-id: work-id }
        { owner: tx-sender }
      )

      (ok true)
    )
  )
)

(define-public (transfer-ownership (work-id uint) (new-owner principal))
  (let
    ((current-owner-data (map-get? owners { work-id: work-id })))

    (asserts! (is-some current-owner-data) (err u404))
    (asserts! (is-eq tx-sender (get owner (unwrap! current-owner-data (err u404)))) (err u403))

    (map-set owners
      { work-id: work-id }
      { owner: new-owner }
    )

    (ok true)
  )
)

;; Helper function to get work data without contract call
(define-private (get-work-data (work-id uint))
  (map-get? works { id: work-id })
)

;; Local copy of works map for reference
(define-map works
  { id: uint }
  {
    creator: principal,
    title: (string-ascii 64),
    hash: (buff 32)
  }
)

;; Function to register work data locally
(define-public (register-work-data (id uint) (creator principal) (title (string-ascii 64)) (hash (buff 32)))
  (begin
    (map-set works
      { id: id }
      {
        creator: creator,
        title: title,
        hash: hash
      }
    )
    (ok true)
  )
)
