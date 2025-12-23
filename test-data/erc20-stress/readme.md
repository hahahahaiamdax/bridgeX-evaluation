## Number of participating accounts
300

## Rules
1. For each transaction, pick one account from the pool of 300 pre-created users as the sender.
2. Every transfer ensures the participating user is new (no repeated sender in the batch).

## Results
1. When concurrency exceeds 200, the transaction fails because the state-sync step needs to touch more than 200 slots.
