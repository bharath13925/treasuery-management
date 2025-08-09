module bharath_addr::AutomatedTreasury {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    struct Treasury has store, key {
        total_balance: u64,          
        operations_allocation: u64,
        reserve_allocation: u64,      
        allocated_operations: u64,
        allocated_reserves: u64,      
    }

    const E_TREASURY_NOT_FOUND: u64 = 1;
    const E_INVALID_ALLOCATION: u64 = 2;
    const E_INSUFFICIENT_FUNDS: u64 = 3;

    public fun initialize_treasury(
        owner: &signer, 
        operations_percent: u64, 
        reserve_percent: u64
    ) {

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

    public fun deposit_and_allocate(
        depositor: &signer, 
        treasury_owner: address, 
        amount: u64
    ) acquires Treasury {
        let treasury = borrow_global_mut<Treasury>(treasury_owner);
        let deposit = coin::withdraw<AptosCoin>(depositor, amount);
        coin::deposit<AptosCoin>(treasury_owner, deposit);

        let operations_amount = (amount * treasury.operations_allocation) / 100;
        let reserves_amount = (amount * treasury.reserve_allocation) / 100;

        treasury.total_balance = treasury.total_balance + amount;
        treasury.allocated_operations = treasury.allocated_operations + operations_amount;
        treasury.allocated_reserves = treasury.allocated_reserves + reserves_amount;
    }

}
