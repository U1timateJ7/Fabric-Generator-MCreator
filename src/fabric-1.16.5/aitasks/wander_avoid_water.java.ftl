<#include "aiconditions.java.ftl">
this.goalSelector.addGoal(${customBlockIndex+1}, new WanderAroundFarGoal(this, ${field$speed})<@conditionCode field$condition/>);