import Testing

// ============================================================
// PROBLEM: 2043. Simple Bank System
// https://leetcode.com/problems/simple-bank-system/
// Difficulty: Medium
// Topics: Design, Array, Hash Table, Simulation
//
// Implement a Bank class that supports transfer, deposit, and
// withdraw on n accounts (1-indexed), rejecting invalid transactions.
//
// Example 1:
//   Input:  ["Bank","withdraw","transfer","deposit","transfer","withdraw"]
//           [[[10,100,20,50,30]],[3,10],[5,1,20],[5,20],[3,4,15],[10,50]]
//   Output: [null,true,true,true,false,false]
//
// Constraints:
//   - n == balance.length
//   - 1 <= n, account, account1, account2 <= 10^5
//   - 0 <= balance[i], money <= 10^12
//   - 1 <= account, account1, account2 <= n
//   - At most 10^4 calls will be made to each function
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(n) init, O(1) per operation
// Space Complexity: O(n) for the hashmap
// ============================================================

private class Bank {

    var accountBalances: [Int: Int] = [:]
    let totalAccountCount: Int

    init(_ balances: [Int]) {
        totalAccountCount = balances.count
        for (index, balance) in balances.enumerated() {
            accountBalances[index + 1] = balance
        }
    }

    func transfer(_ account1: Int, _ account2: Int, _ money: Int) -> Bool {
        guard isAccountValid(account1),
              isAccountValid(account2),
              let currentBalance1 = accountBalances[account1],
              money <= currentBalance1
        else { return false }

        accountBalances[account1]! -= money
        accountBalances[account2]! += money
        return true
    }

    func deposit(_ account: Int, _ money: Int) -> Bool {
        guard isAccountValid(account) else { return false }
        accountBalances[account]! += money
        return true
    }

    func withdraw(_ account: Int, _ money: Int) -> Bool {
        guard isAccountValid(account),
              let currentBalance = accountBalances[account],
              money <= currentBalance
        else { return false }

        accountBalances[account]! -= money
        return true
    }

    private func isAccountValid(_ account: Int) -> Bool {
        account > 0 && account <= totalAccountCount
    }
}


// ============================================================
// TESTS
// ============================================================

@Suite("Simple Bank System")
struct SimpleBankSystemTests {

    // --- Official LeetCode example ---

    @Test("Official example 1")
    func officialExample1() {
        let bank = Bank([10, 100, 20, 50, 30])
        #expect(bank.withdraw(3, 10)       == true)
        #expect(bank.transfer(5, 1, 20)   == true)
        #expect(bank.deposit(5, 20)        == true)
        #expect(bank.transfer(3, 4, 15)   == false)
        #expect(bank.withdraw(10, 50)      == false)
    }

    // --- Edge cases ---

    @Test("Withdraw from account that does not exist")
    func withdrawInvalidAccount() {
        let bank = Bank([500])
        #expect(bank.withdraw(2, 1) == false)
    }

    @Test("Deposit into account that does not exist")
    func depositInvalidAccount() {
        let bank = Bank([0])
        #expect(bank.deposit(0, 100) == false)
    }

    @Test("Transfer to self is valid when funds are sufficient")
    func transferToSelf() {
        let bank = Bank([100])
        #expect(bank.transfer(1, 1, 50) == true)
    }

    @Test("Withdraw exact balance succeeds, then account is empty")
    func withdrawExactBalance() {
        let bank = Bank([200, 0])
        #expect(bank.withdraw(1, 200) == true)
        #expect(bank.withdraw(1, 1)   == false)
    }

    @Test("Transfer fails when source has insufficient funds")
    func transferInsufficientFunds() {
        let bank = Bank([10, 9999])
        #expect(bank.transfer(1, 2, 11) == false)
    }

    @Test("Single account deposit and withdraw round-trip")
    func singleAccountRoundTrip() {
        let bank = Bank([0])
        #expect(bank.deposit(1, 1_000_000_000_000) == true)
        #expect(bank.withdraw(1, 1_000_000_000_000) == true)
        #expect(bank.withdraw(1, 1) == false)
    }
}
