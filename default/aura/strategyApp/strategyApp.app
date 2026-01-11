<aura:application access="GLOBAL" extends="ltng:outApp">
    <aura:dependency resource="c:AccountPlanTaskList"/>
    <aura:dependency resource="c:StakeholderHierarchyChart"/>
    <aura:dependency resource="c:RelationshipMapInfluenceChart"/>
    <aura:dependency resource="c:RelationshipMapSettings" />
    <aura:dependency resource="c:relationshipMatrix"/>
    <aura:dependency resource="c:strategySettings"/>
    <aura:dependency resource="c:swotMatrix"/>
    <aura:dependency resource="c:fieldHistory"/>
    <aura:dependency resource="c:PQBaseSettingsLayout" />
    <aura:dependency resource="c:UserSettingsContainer" />
    <aura:dependency resource="c:planOverview" />
    <aura:dependency resource="c:pqPlanOverview" />
    <aura:dependency resource="c:WhiteSpaceReport" />
    <aura:dependency resource="c:WhiteSpaceReportRecord" />
    <aura:dependency resource="c:WhiteSpaceTemplateBuilder" />
    <aura:dependency resource="c:builderPage" />
    <aura:dependency resource="c:accountOppDatatable" />
    <aura:dependency resource="c:PQApplicationEvent" />
    <aura:dependency resource="c:UpdateAccountTeamSharing" />
    <aura:dependency resource="c:pqObjective" />
    <aura:dependency resource="c:pqObjectiveOverview" />
    <aura:dependency resource="c:dataTableMapMember" />
    <aura:dependency resource="markup://force:*" type="EVENT"/>
</aura:application>