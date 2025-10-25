;; project-solver
;; Short & error-free Clarity project for Google Clarity Web3

(define-data-var project-counter uint u0)

(define-map projects ((id uint))
  ((creator principal)
   (problem (string-ascii 60))
   (solution (string-ascii 60))
   (status (string-ascii 12))))

;; Create a new project with a problem
(define-public (create-project (problem (string-ascii 60)))
  (let ((id (var-get project-counter)))
    (begin
      (map-set projects id
        ((creator tx-sender)
         (problem problem)
         (solution "")
         (status "open")))
      (var-set project-counter (+ id u1))
      (ok id)
    )
  )
)

;; Add a solution to an open project
(define-public (add-solution (id uint) (solution (string-ascii 60)))
  (match (map-get? projects id)
    project
      (if (is-eq (get status project) "open")
          (begin
            (map-set projects id
              ((creator (get creator project))
               (problem (get problem project))
               (solution solution)
               (status "solved")))
            (ok "Solution submitted"))
          (err u1)) ;; project not open
    (err u2) ;; not found
  )
)

;; Approve solved project and grant contract
(define-public (grant-contract (id uint))
  (match (map-get? projects id)
    project
      (if (is-eq (get status project) "solved")
          (begin
            (map-set projects id
              ((creator (get creator project))
               (problem (get problem project))
               (solution (get solution project))
               (status "contracted")))
            (ok "Contract granted"))
          (err u3)) ;; must be solved
    (err u4) ;; not found
  )
)
