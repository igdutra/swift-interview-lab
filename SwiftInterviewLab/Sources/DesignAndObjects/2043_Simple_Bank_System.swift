//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 29/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 2043. Simple Bank System
// https://leetcode.com/problems/simple-bank-system/
// Difficulty: Medium
// Topics: Design, Array, Hash Table, Simulation
//
// Implement a Bank class that supports transfer, deposit, and
// withdraw on n accounts (1-indexed), rejecting invalid transactions.
// Transaction is valid if:
//  The given account number(s) are between 1 and n, and
//  The amount of money withdrawn or transferred from is less than or equal to the balance of the account.
//
//Implement the Bank class:
//
//Bank(long[] balance) Initializes the object with the 0-indexed integer array balance.
//boolean transfer(int account1, int account2, long money) Transfers money dollars from the account numbered account1 to the account numbered account2. Return true if the transaction was successful, false otherwise.
//boolean deposit(int account, long money) Deposit money dollars into the account numbered account. Return true if the transaction was successful, false otherwise.
//boolean withdraw(int account, long money) Withdraw money dollars from the account numbered account. Return true if the transaction was successful, false otherwise.
//
//Input
//["Bank", "withdraw", "transfer", "deposit", "transfer", "withdraw"]
//[[[10, 100, 20, 50, 30]], [3, 10], [5, 1, 20], [5, 20], [3, 4, 15], [10, 50]]
//Output
//[null, true, true, true, false, false]
//
//Explanation
//Bank bank = new Bank([10, 100, 20, 50, 30]);
//bank.withdraw(3, 10);    // return true, account 3 has a balance of $20, so it is valid to withdraw $10.
//                         // Account 3 has $20 - $10 = $10.
//bank.transfer(5, 1, 20); // return true, account 5 has a balance of $30, so it is valid to transfer $20.
//                         // Account 5 has $30 - $20 = $10, and account 1 has $10 + $20 = $30.
//bank.deposit(5, 20);     // return true, it is valid to deposit $20 to account 5.
//                         // Account 5 has $10 + $20 = $30.
//bank.transfer(3, 4, 15); // return false, the current balance of account 3 is $10,
//                         // so it is invalid to transfer $15 from it.
//bank.withdraw(10, 50);   // return false, it is invalid because account 10 does not exist.

//
// Constraints:
//   - n == balance.length
//   - 1 <= n, account, account1, account2 <= 10^5
//   - 0 <= balance[i], money <= 10^12
//   - 1 <= account, account1, account2 <= n
//   - At most 10^4 calls will be made to each function
//
//
//private class Bank {
//
//    // TODO
//
//    init(_ balance: [Int]) {
//        // TODO
//    }
//
//    func transfer(_ account1: Int, _ account2: Int, _ money: Int) -> Bool {
//        // TODO
//        return false
//    }
//
//    func deposit(_ account: Int, _ money: Int) -> Bool {
//        // TODO
//        return false
//    }
//
//    func withdraw(_ account: Int, _ money: Int) -> Bool {
//        // TODO
//        return false
//    }
//}
//
// ============================================================

/* PLAN
 
 QUESTIONS
 - Are all accounts start with positive balance? should treat it?
 - what they mean by (i+1) index? - nada just that balane
 
 PATTERN
 - hashmap - 0(1) lookup
 - state management
 
 SEQUENCE
 - init
    - get dict: index: balance
    - save dictCount
 - transfer: access hashmap, alter its value.
    - POSSILBE optimization: per requiremnt, the functions should not respect the comand0query separation as we will create sideeffects and return bool on each operation - break those into smaller functions
 - withdraw: single check to make, >= amount
 
 - CENTRALIZE behavior: isValidAccount, isTransactionValid(account, amount)
 
 WALK
 
 STATE
 accountsCount
 index
 
 EDGE CASES
 - guard VALID account name 1...accountsCount
 - VALIDADE indexes: account 1 = index 0 !

*/

#Playground {
    let input = [10, 100, 20, 50, 30]
    
    final class Bank {

        var accountBalances: [Int: Int] = [:]
        let totalAccountCount: Int

        init(_ balances: [Int]) {
            totalAccountCount = balances.count
            for (index, balance) in balances.enumerated() {
                // account 3 -> index 2
                accountBalances[index+1] = balance
            }
//            print(totalAccountCount)
//            print(accountBalances)
        }

        func transfer(_ account1: Int, _ account2: Int, _ money: Int) -> Bool {
            guard isAccountValid(account1),
                  isAccountValid(account2),
                  let currentBalance1 = accountBalances[account1]
            else { return false }
            
            if money > currentBalance1 { return false }

            accountBalances[account1, default: 0] -= money
            accountBalances[account2, default: 0] += money
            
            return true
        }

        func deposit(_ account: Int, _ money: Int) -> Bool {
            guard isAccountValid(account)
            else { return false }
            
            accountBalances[account, default: 0] += money
            
            return true
        }

        func withdraw(_ account: Int, _ money: Int) -> Bool {
            guard isAccountValid(account),
                  let currentBalance = accountBalances[account]
            else { return false }
            
            if money > currentBalance { return false }
            
            accountBalances[account, default: 0] -= money
        
            return true
        }
        
        // MARK: - Private methods

        private func isAccountValid(_ account: Int) -> Bool {
            account > 0 && account <= totalAccountCount
        }
    }
    
    let bank = Bank(input)
    print("1", bank.withdraw(3, 10))
    print(bank.accountBalances)
    print("2", bank.transfer(3, 1, 50))
    print(bank.accountBalances)
}
