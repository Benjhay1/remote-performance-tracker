# **Remote Work Performance Bonus Tracker - Smart Contract**

This smart contract provides a system for managing the performance-based bonus structure for remote workers. It allows employers to define tasks, track task completion, evaluate the quality of work, and automatically release performance-based bonuses when certain criteria are met. It is implemented using the **Clarity** language and runs on the **Stacks Blockchain**.

## **Features**
- **Employee Registration**: Remote workers can register in the system to be eligible for bonus tracking and task management.
- **Task Creation**: Employers can create tasks and assign them to remote workers.
- **Task Submission**: Employees can submit completed tasks for review.
- **Task Review and Approval**: Employers can review the submitted tasks, approve or reject them, and assign a quality score.
- **Bonus Distribution**: Bonuses are calculated based on performance and released to employees if the predefined performance threshold is met.
- **Performance Scoring**: Performance is based on the task completion rate, quality score, and a predefined minimum threshold.
- **Automated Payment**: Bonuses are released automatically if the employee's performance score meets the required threshold.

---

## **Contract Overview**
This contract includes the following key components:

### **1. Data Variables:**
- `minimum-performance-threshold`: The performance score threshold that employees must meet to receive a bonus (default value is 80%).
- `bonus-pool`: The total pool of bonuses available to be distributed to employees (initially set to 0).

### **2. Data Maps:**
- `Employees`: A map that tracks the registration status, task completion count, approved tasks count, total bonus earned, and performance score for each employee.
- `Tasks`: A map that tracks the tasks created by employers, with details like the task description, assignee, status, deadline, bonus amount, and quality score.
  
### **3. Task Counter:**
- `task-id-counter`: A variable that automatically increments to generate unique IDs for new tasks.

### **4. Constants:**
- `CONTRACT_OWNER`: The principal address of the contract owner (employer).
- Error codes are predefined to handle common contract errors like unauthorized access, unregistered employees, task not found, and insufficient balance.

---

## **Public Functions**

### **1. `register-employee()`**
Registers a new employee in the system. Once registered, employees are eligible to be assigned tasks and earn performance-based bonuses.
- **Input**: None
- **Output**: Returns `ok` on successful registration or an error if the employee is already registered.

### **2. `create-task(assignee principal, deadline uint, description string-ascii, bonus-amount uint)`**
Allows the employer (contract owner) to create a new task for a remote worker.
- **Input**: 
  - `assignee`: The principal address of the employee to whom the task will be assigned.
  - `deadline`: The deadline (Unix timestamp) by which the task should be completed.
  - `description`: A short description of the task.
  - `bonus-amount`: The bonus that will be awarded upon completion of the task.
- **Output**: Returns the task ID for the newly created task or an error if the employer is not authorized or the assignee is not registered.

### **3. `submit-task(task-id uint)`**
Allows employees to submit completed tasks for review by the employer.
- **Input**: 
  - `task-id`: The unique ID of the task being submitted.
- **Output**: Returns `ok` if the task is successfully submitted or an error if the task is not assigned to the submitting employee or the status is invalid.

### **4. `review-task(task-id uint, approved bool, quality-score uint)`**
Allows the employer to review a submitted task. If the task is approved, a quality score is assigned, and the performance of the employee is updated.
- **Input**: 
  - `task-id`: The unique ID of the task being reviewed.
  - `approved`: Boolean value indicating whether the task was approved (`true`) or rejected (`false`).
  - `quality-score`: A numerical score (0-100) that represents the quality of the task performed.
- **Output**: Returns `ok` if the task review is successful. If approved, the performance score is calculated and the bonus is released (if eligible).

---

## **Private Helper Functions**

### **1. `calculate-performance(approved uint, total uint, quality uint)`**
This function calculates the performance score of an employee based on their task completion rate and the quality of their work. The performance score is a weighted combination of the completion rate and quality score.
- **Input**: 
  - `approved`: The number of tasks approved.
  - `total`: The total number of tasks completed.
  - `quality`: The quality score of the completed task.
- **Output**: Returns the performance score as a percentage (0-100).

### **2. `release-bonus(recipient principal, amount uint)`**
This function releases the calculated bonus to the employee if they meet the performance threshold.
- **Input**: 
  - `recipient`: The principal address of the employee.
  - `amount`: The bonus amount to be transferred.
- **Output**: Returns `ok` if the bonus is successfully transferred or an error if there are insufficient funds.

---

## **Read-Only Functions**

### **1. `get-employee-details(employee principal)`**
This function retrieves the details of a registered employee, including their registration status, task completion count, approved tasks count, total bonus earned, and performance score.
- **Input**: 
  - `employee`: The principal address of the employee.
- **Output**: Returns the employee's details or `null` if the employee is not registered.

### **2. `get-task-details(task-id uint)`**
This function retrieves the details of a specific task, including the task description, assignee, status, bonus amount, and quality score.
- **Input**: 
  - `task-id`: The unique ID of the task.
- **Output**: Returns the task details or `null` if the task is not found.

### **3. `get-performance-score(employee principal)`**
This function retrieves the current performance score of a registered employee.
- **Input**: 
  - `employee`: The principal address of the employee.
- **Output**: Returns the performance score or 0 if the employee has not been registered or has not completed any tasks.

---

## **Contract Owner Responsibilities**
- The contract owner (typically the employer) is responsible for:
  - Registering employees.
  - Creating tasks and assigning them to employees.
  - Reviewing completed tasks and approving or rejecting them.
  - Setting the minimum performance threshold for bonuses.
  - Ensuring sufficient funds are available in the bonus pool for payouts.

---

## **Deployment and Usage**
1. **Deploy the contract** on the Stacks blockchain using the Stacks wallet.
2. **Set the contract owner** address, which will have the authority to create tasks and review performance.
3. Employees can **register** using the `register-employee` function.
4. Employers can **create tasks** using the `create-task` function and assign them to employees.
5. Employees can **submit tasks** for review using the `submit-task` function.
6. Employers can **review tasks** and approve or reject them, assigning a quality score and releasing bonuses where applicable.

---

## **Error Handling**
The contract includes the following error codes for handling common issues:
- `ERR_OWNER_ONLY`: Raised when an unauthorized person tries to call an admin-only function.
- `ERR_NOT_REGISTERED`: Raised when an employee who is not registered attempts to submit or be assigned a task.
- `ERR_ALREADY_REGISTERED`: Raised when an employee tries to register more than once.
- `ERR_TASK_NOT_FOUND`: Raised when an invalid task ID is provided.
- `ERR_INVALID_STATUS`: Raised when trying to modify a task that is not in the correct state.
- `ERR_INSUFFICIENT_BALANCE`: Raised if the employer does not have enough balance to pay the bonus.

---

The **Remote Work Performance Bonus Tracker** smart contract offers an efficient, transparent, and automated way to manage employee performance and bonuses. It ensures that both employers and employees are aligned on expectations, promotes fairness, and reduces administrative overhead.