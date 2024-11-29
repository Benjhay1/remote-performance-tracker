;; Remote Work Performance Bonus Tracker
;; A contract for managing remote worker performance and bonuses

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-registered (err u101))
(define-constant err-already-registered (err u102))
(define-constant err-task-not-found (err u103))
(define-constant err-invalid-status (err u104))
(define-constant err-insufficient-balance (err u105))

;; Data Variables
(define-data-var minimum-performance-threshold uint u80)
(define-data-var bonus-pool uint u0)

;; Data Maps
(define-map Employees 
    principal 
    {
        registered: bool,
        total-tasks-completed: uint,
        total-tasks-approved: uint,
        total-bonus-earned: uint,
        performance-score: uint
    }
)

(define-map Tasks 
    uint 
    {
        owner: principal,
        assignee: principal,
        deadline: uint,
        description: (string-ascii 256),
        status: (string-ascii 20),
        bonus-amount: uint,
        quality-score: uint
    }
)

;; Task counter
(define-data-var task-id-counter uint u0)

;; Public Functions

;; Register new employee
(define-public (register-employee)
    (let ((sender tx-sender))
        (asserts! (is-none (get registered (map-get? Employees sender))) (err-already-registered))
        (ok (map-set Employees 
            sender
            {
                registered: true,
                total-tasks-completed: u0,
                total-tasks-approved: u0,
                total-bonus-earned: u0,
                performance-score: u0
            }
        ))
    )
)

;; Create new task
(define-public (create-task (assignee principal) 
                           (deadline uint) 
                           (description (string-ascii 256))
                           (bonus-amount uint))
    (let ((new-task-id (+ (var-get task-id-counter) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-some (map-get? Employees assignee)) err-not-registered)
        
        (map-set Tasks new-task-id
            {
                owner: tx-sender,
                assignee: assignee,
                deadline: deadline,
                description: description,
                status: "ASSIGNED",
                bonus-amount: bonus-amount,
                quality-score: u0
            }
        )
        (var-set task-id-counter new-task-id)
        (ok new-task-id)
    )
)

;; Submit completed task
(define-public (submit-task (task-id uint))
    (let ((task (unwrap! (map-get? Tasks task-id) err-task-not-found))
          (employee (unwrap! (map-get? Employees tx-sender) err-not-registered)))
        
        (asserts! (is-eq (get assignee task) tx-sender) err-owner-only)
        (asserts! (is-eq (get status task) "ASSIGNED") err-invalid-status)
        
        (map-set Tasks task-id
            (merge task { status: "SUBMITTED" })
        )
        
        (map-set Employees tx-sender
            (merge employee 
                { total-tasks-completed: (+ (get total-tasks-completed employee) u1) })
        )
        (ok true)
    )
)

;; Review and approve task
(define-public (review-task (task-id uint) (approved bool) (quality-score uint))
    (let ((task (unwrap! (map-get? Tasks task-id) err-task-not-found))
          (employee (unwrap! (map-get? Employees (get assignee task)) err-not-registered)))
        
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-eq (get status task) "SUBMITTED") err-invalid-status)
        
        (if approved
            (begin
                (map-set Tasks task-id
                    (merge task 
                        { 
                            status: "APPROVED",
                            quality-score: quality-score
                        }
                    ))
                
                (map-set Employees (get assignee task)
                    (merge employee 
                        { 
                            total-tasks-approved: (+ (get total-tasks-approved employee) u1),
                            performance-score: (calculate-performance 
                                (get total-tasks-approved employee) 
                                (get total-tasks-completed employee)
                                quality-score
                            )
                        }
                    ))
                
                ;; Release bonus if performance threshold is met
                (if (>= (get performance-score employee) (var-get minimum-performance-threshold))
                    (release-bonus (get assignee task) (get bonus-amount task))
                    (ok true)
                ))
            
            ;; If not approved
            (begin
                (map-set Tasks task-id
                    (merge task { status: "REJECTED" }))
                (ok true)
            ))
    )
)

;; Private helper functions

;; Calculate performance score based on completion rate and quality
(define-private (calculate-performance (approved uint) (total uint) (quality uint))
    (if (is-eq total u0)
        u0
        (/ (* (+ (* (/ (* approved u100) total) u1) quality) u100) u2)
    )
)

;; Release bonus payment
(define-private (release-bonus (recipient principal) (amount uint))
    (let ((balance (stx-get-balance contract-owner)))
        (asserts! (>= balance amount) err-insufficient-balance)
        (try! (stx-transfer? amount contract-owner recipient))
        (ok true)
    )
)

;; Read-only functions

;; Get employee details
(define-read-only (get-employee-details (employee principal))
    (map-get? Employees employee)
)

;; Get task details
(define-read-only (get-task-details (task-id uint))
    (map-get? Tasks task-id)
)

;; Get current performance score
(define-read-only (get-performance-score (employee principal))
    (get performance-score (default-to 
        { 
            registered: false,
            total-tasks-completed: u0,
            total-tasks-approved: u0,
            total-bonus-earned: u0,
            performance-score: u0
        }
        (map-get? Employees employee)))
)