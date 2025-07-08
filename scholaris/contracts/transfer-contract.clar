;; Private Tutor Marketplace Smart Contract
;; A platform for tutors and educators to showcase teaching credentials and student success stories

;; Commit: feat: launch private tutor marketplace with teaching credentials and student success tracking system

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-openness (err u104))

;; Openness levels
(define-constant OPENNESS-PUBLIC u0)
(define-constant OPENNESS-QUALIFIED-TUTORS u1)
(define-constant OPENNESS-PRIVATE u2)

;; Data Variables
(define-data-var tutoring-fee uint u550) ;; 0.055% fee in basis points

;; Data Maps

;; Tutor profiles
(define-map tutor-profiles
  { tutor: principal }
  {
    educator-name: (string-ascii 100),
    subject-expertise: (string-ascii 200),
    teaching-region: (string-ascii 100),
    profile-openness: uint,
    started-at: uint,
    is-qualified: bool
  }
)

;; Student success stories
(define-map student-successes
  { tutor: principal, success-id: uint }
  {
    subject-area: (string-ascii 100),
    achievement-type: (string-ascii 100),
    success-date: uint,
    tutoring-start: (optional uint),
    success-description: (string-ascii 500),
    openness-level: uint,
    documented-at: uint
  }
)

;; Tutor success counters
(define-map tutor-success-count
  { tutor: principal }
  { count: uint }
)

;; Teaching credentials
(define-map teaching-credentials
  { tutor: principal, credential-id: uint }
  {
    qualification-name: (string-ascii 100),
    granting-body: (string-ascii 100),
    earned-date: uint,
    valid-until: (optional uint),
    credential-hash: (buff 32),
    openness-level: uint,
    is-verified: bool,
    documented-at: uint
  }
)

;; Tutor credential counters
(define-map tutor-credential-count
  { tutor: principal }
  { count: uint }
)

;; Student testimonials
(define-map student-testimonials
  { tutor: principal, testimonial-id: uint }
  {
    subject-focus: (string-ascii 50),
    recommending-student: principal,
    testimonial-content: (string-ascii 300),
    submitted-at: uint
  }
)

;; Tutor testimonial counters
(define-map tutor-testimonial-count
  { tutor: principal }
  { count: uint }
)

;; Educational networks
(define-map educational-networks
  { tutor1: principal, tutor2: principal }
  {
    network-status: (string-ascii 20), ;; "pending", "connected", "inactive"
    initiated-by: principal,
    networked-at: uint
  }
)

;; Subject focus endorsement counts
(define-map subject-endorsements
  { tutor: principal, subject: (string-ascii 50) }
  { count: uint }
)

;; Read-only functions

;; Get tutor profile
(define-read-only (get-tutor-profile (tutor principal))
  (map-get? tutor-profiles { tutor: tutor })
)

;; Get student success
(define-read-only (get-student-success (tutor principal) (success-id uint))
  (map-get? student-successes { tutor: tutor, success-id: success-id })
)

;; Get teaching credential
(define-read-only (get-teaching-credential (tutor principal) (credential-id uint))
  (map-get? teaching-credentials { tutor: tutor, credential-id: credential-id })
)

;; Get student testimonial
(define-read-only (get-student-testimonial (tutor principal) (testimonial-id uint))
  (map-get? student-testimonials { tutor: tutor, testimonial-id: testimonial-id })
)

;; Get network status
(define-read-only (get-network-status (tutor1 principal) (tutor2 principal))
  (map-get? educational-networks { tutor1: tutor1, tutor2: tutor2 })
)

;; Get subject endorsement count
(define-read-only (get-subject-endorsement-count (tutor principal) (subject (string-ascii 50)))
  (default-to u0 (get count (map-get? subject-endorsements { tutor: tutor, subject: subject })))
)

;; Check if tutors are networked
(define-read-only (are-tutors-networked (tutor1 principal) (tutor2 principal))
  (let ((network1 (map-get? educational-networks { tutor1: tutor1, tutor2: tutor2 }))
        (network2 (map-get? educational-networks { tutor1: tutor2, tutor2: tutor1 })))
    (or
      (and (is-some network1) (is-eq (get network-status (unwrap-panic network1)) "connected"))
      (and (is-some network2) (is-eq (get network-status (unwrap-panic network2)) "connected"))
    )
  )
)

;; Check if tutor can view private content
(define-read-only (can-view-private-content (owner principal) (viewer principal) (openness-level uint))
  (or
    (is-eq owner viewer)
    (is-eq openness-level OPENNESS-PUBLIC)
    (and 
      (is-eq openness-level OPENNESS-QUALIFIED-TUTORS)
      (are-tutors-networked owner viewer)
    )
  )
)

;; Public functions

;; Create tutor profile
(define-public (create-tutor-profile (educator-name (string-ascii 100)) (subject-expertise (string-ascii 200)) (teaching-region (string-ascii 100)) (profile-openness uint))
  (begin
    (asserts! (<= profile-openness OPENNESS-PRIVATE) err-invalid-openness)
    (ok (map-set tutor-profiles
      { tutor: tx-sender }
      {
        educator-name: educator-name,
        subject-expertise: subject-expertise,
        teaching-region: teaching-region,
        profile-openness: profile-openness,
        started-at: block-height,
        is-qualified: false
      }
    ))
  )
)

;; Document student success
(define-public (document-student-success (subject-area (string-ascii 100)) (achievement-type (string-ascii 100)) (success-date uint) (tutoring-start (optional uint)) (success-description (string-ascii 500)) (openness-level uint))
  (let ((current-count (default-to u0 (get count (map-get? tutor-success-count { tutor: tx-sender })))))
    (begin
      (asserts! (<= openness-level OPENNESS-PRIVATE) err-invalid-openness)
      (map-set student-successes
        { tutor: tx-sender, success-id: current-count }
        {
          subject-area: subject-area,
          achievement-type: achievement-type,
          success-date: success-date,
          tutoring-start: tutoring-start,
          success-description: success-description,
          openness-level: openness-level,
          documented-at: block-height
        }
      )
      (map-set tutor-success-count
        { tutor: tx-sender }
        { count: (+ current-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Add teaching credential
(define-public (add-teaching-credential (qualification-name (string-ascii 100)) (granting-body (string-ascii 100)) (earned-date uint) (valid-until (optional uint)) (credential-hash (buff 32)) (openness-level uint))
  (let ((current-count (default-to u0 (get count (map-get? tutor-credential-count { tutor: tx-sender })))))
    (begin
      (asserts! (<= openness-level OPENNESS-PRIVATE) err-invalid-openness)
      (map-set teaching-credentials
        { tutor: tx-sender, credential-id: current-count }
        {
          qualification-name: qualification-name,
          granting-body: granting-body,
          earned-date: earned-date,
          valid-until: valid-until,
          credential-hash: credential-hash,
          openness-level: openness-level,
          is-verified: false,
          documented-at: block-height
        }
      )
      (map-set tutor-credential-count
        { tutor: tx-sender }
        { count: (+ current-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Send network request
(define-public (send-network-request (target-tutor principal))
  (begin
    (asserts! (not (is-eq tx-sender target-tutor)) err-unauthorized)
    (asserts! (is-none (map-get? educational-networks { tutor1: tx-sender, tutor2: target-tutor })) err-already-exists)
    (asserts! (is-none (map-get? educational-networks { tutor1: target-tutor, tutor2: tx-sender })) err-already-exists)
    (ok (map-set educational-networks
      { tutor1: tx-sender, tutor2: target-tutor }
      {
        network-status: "pending",
        initiated-by: tx-sender,
        networked-at: block-height
      }
    ))
  )
)

;; Accept network request
(define-public (accept-network-request (requesting-tutor principal))
  (let ((network (map-get? educational-networks { tutor1: requesting-tutor, tutor2: tx-sender })))
    (begin
      (asserts! (is-some network) err-not-found)
      (asserts! (is-eq (get network-status (unwrap-panic network)) "pending") err-unauthorized)
      (ok (map-set educational-networks
        { tutor1: requesting-tutor, tutor2: tx-sender }
        {
          network-status: "connected",
          initiated-by: requesting-tutor,
          networked-at: (get networked-at (unwrap-panic network))
        }
      ))
    )
  )
)

;; Submit student testimonial
(define-public (submit-student-testimonial (tutor principal) (subject-focus (string-ascii 50)) (testimonial-content (string-ascii 300)))
  (let ((current-count (default-to u0 (get count (map-get? tutor-testimonial-count { tutor: tutor }))))
        (current-subject-count (default-to u0 (get count (map-get? subject-endorsements { tutor: tutor, subject: subject-focus })))))
    (begin
      (asserts! (not (is-eq tx-sender tutor)) err-unauthorized)
      (asserts! (are-tutors-networked tx-sender tutor) err-unauthorized)
      (map-set student-testimonials
        { tutor: tutor, testimonial-id: current-count }
        {
          subject-focus: subject-focus,
          recommending-student: tx-sender,
          testimonial-content: testimonial-content,
          submitted-at: block-height
        }
      )
      (map-set tutor-testimonial-count
        { tutor: tutor }
        { count: (+ current-count u1) }
      )
      (map-set subject-endorsements
        { tutor: tutor, subject: subject-focus }
        { count: (+ current-subject-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Verify teaching credential (admin only)
(define-public (verify-teaching-credential (tutor principal) (credential-id uint))
  (let ((credential (map-get? teaching-credentials { tutor: tutor, credential-id: credential-id })))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (is-some credential) err-not-found)
      (ok (map-set teaching-credentials
        { tutor: tutor, credential-id: credential-id }
        (merge (unwrap-panic credential) { is-verified: true })
      ))
    )
  )
)

;; Qualify tutor (admin only)
(define-public (qualify-tutor (tutor principal))
  (let ((profile (map-get? tutor-profiles { tutor: tutor })))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (is-some profile) err-not-found)
      (ok (map-set tutor-profiles
        { tutor: tutor }
        (merge (unwrap-panic profile) { is-qualified: true })
      ))
    )
  )
)

;; Update tutoring fee (admin only)
(define-public (update-tutoring-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set tutoring-fee new-fee)
    (ok true)
  )
)