#  PROJECT PLAN

## Feature Overview
    1. Create budgets
        * categorize transactions into each of the budgets
        * display an over/under for the desired period
        * can set different budgets for different time lengths (weekly, monthly, annually)
    2. Integrate online banking app to get real-time updates of transactions
        * can place a transaction into one of the created budgets

Ideas to implement:
1. When you select a sub-budget, the transactions associated with that sub-budget will be filtered to be the only transactions displayed
2. When you are on the budgets tab, it gives you all the associated transactions (instead of sub-budgets) in order of recency
3. There should be an option to move a transaction from one sub-budget to another (or to no sub-budget at all) within the budgets tab, and into a specific budget when on the transactions tab
4. By default there should be no sub-budget, but instead a default sub-budget with "" as its name. If a transaction is not placed into a specific sub-budget, it will be placed into here.
