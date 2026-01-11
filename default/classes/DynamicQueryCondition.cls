@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class DynamicQueryCondition {
    private Query.Condition condition;
    private DynamicQueryCondition() {
        condition = null;
    }
    private DynamicQueryCondition(Query.Condition condition) {
        this.condition = condition;
    }

    public Query.Condition getCondition() {
        return this.condition;
    }

    public DynamicQueryCondition doAnd(DynamicQueryCondition other) {
        DynamicQueryCondition newCondition = this.clone();
        newCondition.condition = this.condition.doAnd(other.condition);
        return newCondition;
    }

    public DynamicQueryCondition doOr(DynamicQueryCondition other) {
        DynamicQueryCondition newCondition = this.clone();
        newCondition.condition = this.condition.doOr(other.condition);
        return newCondition;
    }

    public DynamicQueryCondition doNot() {
        DynamicQueryCondition newCondition = this.clone();
        newCondition.condition = this.condition.doNot();
        return newCondition;
    }

    /*
     * Create a condition
     * Example: conditionEq('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate = :Datetime.now()"
     */
    public static DynamicQueryCondition conditionEq(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionEq(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionEq(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate = :Datetime.now()"
     */
    public static DynamicQueryCondition conditionEq(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionEq(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionNotEq('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate != :Datetime.now()"
     */
    public static DynamicQueryCondition conditionNotEq(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionNotEq(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionNotEq(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate != :Datetime.now()"
     */
    public static DynamicQueryCondition conditionNotEq(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionNotEq(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionNull('Name')
     *          the condition is equivalent to "Name = null"
     */
    public static DynamicQueryCondition conditionNull(String field) {
        return new DynamicQueryCondition(Query.conditionNull(field));
    }

    /*
     * Add a condition
     * Example: conditionNull(Account.Name)
     *          the condition is equivalent to "Name = null"
     */
    public static DynamicQueryCondition conditionNull(Schema.SObjectField field) {
        return new DynamicQueryCondition(Query.conditionNull(field));
    }

    /*
     * Add a condition
     * Example: conditionNotNull('Name')
     *          the condition is equivalent to "Name != null"
     */
    public static DynamicQueryCondition conditionNotNull(String field) {
        return new DynamicQueryCondition(Query.conditionNotNull(field));
    }

    /*
     * Add a condition
     * Example: conditionNotNull(Account.Name)
     *          the condition is equivalent to "Name != null"
     */
    public static DynamicQueryCondition conditionNotNull(Schema.SObjectField field) {
        return new DynamicQueryCondition(Query.conditionNotNull(field));
    }

    /*
     * Create a condition
     * Example: conditionIn('Name', mySet)
     *          the condition is equivalent to "Name IN :mySet"
     */
    public static DynamicQueryCondition conditionIn(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionIn(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionIn(Account.Name, mySet)
     *          the condition is equivalent to "Name IN :mySet"
     */
    public static DynamicQueryCondition conditionIn(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionIn(lhs, rhs));
    }

    /*
     * Create a semi-join condition
     * Example: conditionIn('Id', new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id IN (SELECT AccountId FROM Opportunity)"
     */
    public static DynamicQueryCondition conditionIn(String lhs, Query rhs) {
        return new DynamicQueryCondition(Query.conditionIn(lhs, rhs));
    }

    /*
     * Create a semi-join condition
     * Example: conditionIn(Account.Id, new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id IN (SELECT AccountId FROM Opportunity)"
     */
    public static DynamicQueryCondition conditionIn(Schema.SObjectField lhs, Query rhs) {
        return new DynamicQueryCondition(Query.conditionIn(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionNotIn('Name', mySet)
     *          the condition is equivalent to "Name NOT IN :mySet"
     */
    public static DynamicQueryCondition conditionNotIn(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionNotIn(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionNotIn(Account.Name, mySet)
     *          the condition is equivalent to "Name NOT IN :mySet"
     */
    public static DynamicQueryCondition conditionNotIn(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionNotIn(lhs, rhs));
    }

    /*
     * Create an anti-join condition
     * Example: conditionNotIn('Id', new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id NOT IN (SELECT AccountId FROM Opportunity)"
     */
    public static DynamicQueryCondition conditionNotIn(String lhs, Query rhs) {
        return new DynamicQueryCondition(Query.conditionNotIn(lhs, rhs));
    }

    /*
     * Create an anti-join condition
     * Example: conditionNotIn(Account.Id, new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id NOT IN (SELECT AccountId FROM Opportunity)"
     */
    public static DynamicQueryCondition conditionNotIn(Schema.SObjectField lhs, Query rhs) {
        return new DynamicQueryCondition(Query.conditionNotIn(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionLt('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public static DynamicQueryCondition conditionLt(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionLt(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionLt(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public static DynamicQueryCondition conditionLt(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionLt(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionLe('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate <= :Datetime.now()"
     */
    public static DynamicQueryCondition conditionLe(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionLe(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionLe(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate <= :Datetime.now()"
     */
    public static DynamicQueryCondition conditionLe(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionLe(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionGt('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public static DynamicQueryCondition conditionGt(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionGt(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionGt(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public static DynamicQueryCondition conditionGt(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionGt(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionGe('CreatedDate', Datetime.now())
     *          is equivaGent to "CreatedDate <= :Datetime.now()"
     */
    public static DynamicQueryCondition conditionGe(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionGe(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionGe(Account.CreatedDate, Datetime.now())
     *          is equivaGent to "CreatedDate <= :Datetime.now()"
     */
    public static DynamicQueryCondition conditionGe(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionGe(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionLike('Name', '%Sam%')
     *          the condition is equivalent to "Name LIKE '%Sam%'"
     */
    public static DynamicQueryCondition conditionLike(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionLike(lhs, rhs));
    }

    /*
     * Example: conditionLike(Account.Name, '%Sam%')
     *          the condition is equivalent to "Name Like :Datetime.now()"
     */
    public static DynamicQueryCondition conditionLike(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionLike(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionNotLike('Name', '%Sam%')
     *          the condition is equivalent to "NOT Name LIKE '%Sam%'"
     */
    public static DynamicQueryCondition conditionNotLike(String lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionNotLike(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionNotLike(Account.Name, '%Sam%')
     *          the condition is equivalent to "NOT Name LIKE '%Sam%'"
     */
    public static DynamicQueryCondition conditionNotLike(Schema.SObjectField lhs, Object rhs) {
        return new DynamicQueryCondition(Query.conditionNotLike(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionIncludes('Channel', 'MyChannel')
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionIncludes(String lhs, String rhs) {
        return new DynamicQueryCondition(Query.conditionIncludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionIncludes(QuickText.Channel, 'MyChannel')
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionIncludes(Schema.SObjectField lhs, String rhs) {
        return new DynamicQueryCondition(Query.conditionIncludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionIncludes(Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionIncludes(String lhs, List<String> rhs) {
        return new DynamicQueryCondition(Query.conditionIncludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionIncludes(QuickText.Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionIncludes(Schema.SObjectField lhs, List<String> rhs) {
        return new DynamicQueryCondition(Query.conditionIncludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionIncludes(Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionIncludes(String lhs, Set<String> rhs) {
        return new DynamicQueryCondition(Query.conditionIncludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionIncludes(QuickText.Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionIncludes(Schema.SObjectField lhs, Set<String> rhs) {
        return new DynamicQueryCondition(Query.conditionIncludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionExcludes(Channel, 'MyChannel')
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */

    public static DynamicQueryCondition conditionExcludes(String lhs, String rhs) {
        return new DynamicQueryCondition(Query.conditionExcludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionExcludes(QuickText.Channel, 'MyChannel')
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */

    public static DynamicQueryCondition conditionExcludes(Schema.SObjectField lhs, String rhs) {
        return new DynamicQueryCondition(Query.conditionExcludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionExcludes(Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionExcludes(String lhs, List<String> rhs) {
        return new DynamicQueryCondition(Query.conditionExcludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionExcludes(QuickText.Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionExcludes(Schema.SObjectField lhs, List<String> rhs) {
        return new DynamicQueryCondition(Query.conditionExcludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionExcludes(Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionExcludes(String lhs, Set<String> rhs) {
        return new DynamicQueryCondition(Query.conditionExcludes(lhs, rhs));
    }

    /*
     * Create a condition
     * Example: conditionExcludes(QuickText.Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */
    public static DynamicQueryCondition conditionExcludes(Schema.SObjectField lhs, Set<String> rhs) {
        return new DynamicQueryCondition(Query.conditionExcludes(lhs, rhs));
    }

    public static DynamicQueryCondition doAnd(DynamicQueryCondition lhs, DynamicQueryCondition rhs) {
        return new DynamicQueryCondition(Query.doAnd(lhs.condition, rhs.condition));
    }

    public static DynamicQueryCondition doAnd(
        DynamicQueryCondition condition0,
        DynamicQueryCondition condition1,
        DynamicQueryCondition condition2
    ) {
        return new DynamicQueryCondition(Query.doAnd(condition0.condition, condition1.condition, condition2.condition));
    }

    public static DynamicQueryCondition doAnd(
        DynamicQueryCondition condition0,
        DynamicQueryCondition condition1,
        DynamicQueryCondition condition2,
        DynamicQueryCondition condition3
    ) {
        return new DynamicQueryCondition(
            Query.doAnd(condition0.condition, condition1.condition, condition2.condition, condition3.condition)
        );
    }

    public static DynamicQueryCondition doAnd(List<DynamicQueryCondition> conditions) {
        List<Query.Condition> conditionList = new List<Query.Condition>();
        for (DynamicQueryCondition con : conditions) {
            conditionList.add(con.condition);
        }
        return new DynamicQueryCondition(Query.doAnd(conditionList));
    }

    public static DynamicQueryCondition doOr(DynamicQueryCondition lhs, DynamicQueryCondition rhs) {
        return new DynamicQueryCondition(Query.doOr(lhs.condition, rhs.condition));
    }

    public static DynamicQueryCondition doOr(
        DynamicQueryCondition condition0,
        DynamicQueryCondition condition1,
        DynamicQueryCondition condition2
    ) {
        return new DynamicQueryCondition(Query.doOr(condition0.condition, condition1.condition, condition2.condition));
    }

    public static DynamicQueryCondition doOr(
        DynamicQueryCondition condition0,
        DynamicQueryCondition condition1,
        DynamicQueryCondition condition2,
        DynamicQueryCondition condition3
    ) {
        return new DynamicQueryCondition(
            Query.doOr(condition0.condition, condition1.condition, condition2.condition, condition3.condition)
        );
    }

    public static DynamicQueryCondition doOr(List<DynamicQueryCondition> conditions) {
        List<Query.Condition> conditionList = new List<Query.Condition>();
        for (DynamicQueryCondition con : conditions) {
            conditionList.add(con.condition);
        }
        return new DynamicQueryCondition(Query.doOr(conditionList));
    }

    public static DynamicQueryCondition doNot(DynamicQueryCondition condition) {
        return new DynamicQueryCondition(Query.doNot(condition.condition));
    }
}