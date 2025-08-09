module bharath_addr::AutomatedTreasury {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing the treasury with allocation rules
    struct Treasury has store, key {
        total_balance: u64,           // Total treasury balance
        operations_allocation: u64,   // Percentage for operations (out of 100)
        reserve_allocation: u64,      // Percentage for reserves (out of 100)
        allocated_operations: u64,    // Total allocated to operations
        allocated_reserves: u64,      // Total allocated to reserves
    }

    /// Error codes
    const E_TREASURY_NOT_FOUND: u64 = 1;
    const E_INVALID_ALLOCATION: u64 = 2;
    const E_INSUFFICIENT_FUNDS: u64 = 3;

    /// Function to initialize treasury with allocation percentages
    public fun initialize_treasury(
        owner: &signer, 
        operations_percent: u64, 
        reserve_percent: u64
    ) {
        // Ensure allocations add up to 100%
        assert!(operations_percent + reserve_percent == 100, E_INVALID_ALLOCATION);
        
        let treasury = Treasury {
            total_balance: 0,
            operations_allocation: operations_percent,
            reserve_allocation: reserve_percent,
            allocated_operations: 0,
            allocated_reserves: 0,
        };
        move_to(owner, treasury);
    }

    /// Function to deposit funds and automatically allocate them
    public fun deposit_and_allocate(
        depositor: &signer, 
        treasury_owner: address, 
        amount: u64
    ) acquires Treasury {
        let treasury = borrow_global_mut<Treasury>(treasury_owner);
        
        // Transfer funds to treasury owner
        let deposit = coin::withdraw<AptosCoin>(depositor, amount);
        coin::deposit<AptosCoin>(treasury_owner, deposit);
        
        // Calculate automatic allocations
        let operations_amount = (amount * treasury.operations_allocation) / 100;
        let reserves_amount = (amount * treasury.reserve_allocation) / 100;
        
        // Update treasury balances
        treasury.total_balance = treasury.total_balance + amount;
        treasury.allocated_operations = treasury.allocated_operations + operations_amount;
        treasury.allocated_reserves = treasury.allocated_reserves + reserves_amount;
    }
}