<#--
This file is part of Fabric-Generator-MCreator.

MCreatorFabricGenerator is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MCreatorFabricGenerator is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with MCreatorFabricGenerator.  If not, see <https://www.gnu.org/licenses/>.
-->

<#-- @formatter:off -->
<#include "../biomes.java.ftl">
<#include "../procedures.java.ftl">

package ${package}.entity;

import net.fabricmc.fabric.api.object.builder.v1.entity.FabricDefaultAttributeRegistry;
import net.fabricmc.fabric.api.object.builder.v1.entity.FabricEntityTypeBuilder;

@SuppressWarnings("deprecation")
<#assign extendsClass = "Passive">
	<#if data.aiBase != "(none)" >
	    <#assign extendsClass = data.aiBase>
	<#else>
	    <#assign extendsClass = data.mobBehaviourType.replace("Mob", "Hostile").replace("Creature", "Passive")>
	</#if>

	<#if data.breedable>
	    <#assign extendsClass = "Animal">
	</#if>

	<#if data.tameable>
		<#assign extendsClass = "Tameable">
	</#if>
public class ${name}Entity extends ${extendsClass}Entity {

    public static final EntityType<${name}Entity> ENTITY = Registry.register(
            Registry.ENTITY_TYPE,
            ${JavaModName}.id("${registryname}"),
            FabricEntityTypeBuilder.create(${generator.map(data.mobSpawningType, "mobspawntypes")}, ${name}Entity::new)
            .dimensions(EntityDimensions.fixed(${data.modelWidth}f, ${data.modelHeight}f))
            <#if data.immuneToFire>.immuneToFire()</#if>
            .trackRangeBlocks(${data.trackingRange})
            .forceTrackedVelocityUpdates(true).trackedUpdateRate(3)
            .build()
    );

    <#if data.isBoss>
        private final ServerBossBar bossBar;
    </#if>

    protected ${name}Entity(EntityType<? extends ${name}Entity> entityType, World world) {
        super(entityType, world);
		this.setAiDisabled(${(!data.hasAI)});
		this.experiencePoints = ${data.xpAmount};

        <#if data.isBoss>
            this.bossBar = new ServerBossBar(this.getDisplayName(), BossBar.Color.${data.bossBarColor}, BossBar.Style.${data.bossBarType});
        </#if>

		<#if data.mobLabel?has_content >
            setCustomName(new StringTextComponent("${data.mobLabel}"));
            setCustomNameVisible(true);
        </#if>

		<#if !data.doesDespawnWhenIdle>
            setPersistent();
        </#if>

		<#if !data.equipmentMainHand.isEmpty()>
            this.equipLootStack(EquipmentSlot.MAINHAND, ${mappedMCItemToItemStackCode(data.equipmentMainHand, 1)});
        </#if>
        <#if !data.equipmentOffHand.isEmpty()>
            this.equipLootStack(EquipmentSlot.OFFHAND, ${mappedMCItemToItemStackCode(data.equipmentOffHand, 1)});
            </#if>
        <#if !data.equipmentHelmet.isEmpty()>
            this.equipLootStack(EquipmentSlot.HEAD, ${mappedMCItemToItemStackCode(data.equipmentHelmet, 1)});
        </#if>
        <#if !data.equipmentBody.isEmpty()>
            this.equipLootStack(EquipmentSlot.CHEST, ${mappedMCItemToItemStackCode(data.equipmentBody, 1)});
        </#if>
        <#if !data.equipmentLeggings.isEmpty()>
            this.equipLootStack(
		EquipmentSlot.LEGS, ${mappedMCItemToItemStackCode(data.equipmentLeggings, 1)});
        </#if>
        <#if !data.equipmentBoots.isEmpty()>
            this.equipLootStack(EquipmentSlot.FEET, ${mappedMCItemToItemStackCode(data.equipmentBoots, 1)});
        </#if>
        <#if data.flyingMob>
            this.moveControl = new FlightMoveControl(this, 10, true);
            this.navigation = new BirdNavigation(this, this.world);
        </#if>
    }

    <#if data.stepSound?has_content && data.stepSound.getMappedValue()?has_content>
     		@Override public void playStepSound(BlockPos pos, BlockState state) {
     this.playSound(<#if data.stepSound?contains(modid)>${JavaModName}.${data.stepSound?remove_beginning(modid + ":")}Event<#elseif (data.stepSound?length > 0)>
                               SoundEvents.${data.stepSound}<#else>null</#if>, 0.15f, 1);
     		}
    </#if>

    <#if !data.mobDrop.isEmpty()>
        @Override
    	    protected void dropLoot(DamageSource source, boolean causedByPlayer) {
    		    super.dropLoot(source, causedByPlayer);
    		    this.dropStack((${mappedMCItemToItemStackCode(data.mobDrop, 1)});
    	    }
    </#if>

    @Nullable
    @Override
    protected SoundEvent getAmbientSound() {
        return <#if data.livingSound?contains(modid)>${JavaModName}.${data.livingSound?remove_beginning(modid + ":")}Event<#elseif (data.livingSound?length > 0)>
               SoundEvents.${data.livingSound}<#else>null</#if>;
    }

    @Nullable
	@Override
	protected SoundEvent getHurtSound(DamageSource source) {
		return <#if data.hurtSound?contains(modid)>${JavaModName}.${data.hurtSound?remove_beginning(modid + ":")}Event<#elseif (data.hurtSound?length > 0)>
                SoundEvents.${data.hurtSound}<#else>null</#if>;
	}

    @Nullable
	@Override
	protected SoundEvent getDeathSound() {
		return <#if data.deathSound?contains(modid)>${JavaModName}.${data.deathSound?remove_beginning(modid + ":")}Event<#elseif (data.deathSound?length > 0)>
                 SoundEvents.${data.deathSound}<#else>null</#if>;
	}

    <#if data.stepSound?has_content && data.stepSound.getMappedValue()?has_content>
	@Override
	public void playStepSound(BlockPos pos, BlockState blockIn) {
	    this.playSound(<#if data.stepSound?contains(modid)>${JavaModName}.${data.stepSound?remove_beginning(modid + ":")}Event
	        <#elseif (data.stepSound?length > 0)>SoundEvents.${data.stepSound}<#else>null</#if>, 0.15f, 1);
	}
	</#if>

    <#if data.isBoss>
        @Override
        public void readCustomDataFromTag(CompoundTag tag) {
            super.readCustomDataFromTag(tag);
            if (this.hasCustomName()) {
             this.bossBar.setName(this.getDisplayName());
            }
        }

        @Override
        public void setCustomName(@Nullable Text name) {
            super.setCustomName(name);
            this.bossBar.setName(this.getDisplayName());
        }

        @Override
        protected void mobTick() {
            super.mobTick();
            this.bossBar.setPercent(this.getHealth() / this.getMaxHealth());
        }

        @Override
        public void onStartedTrackingBy(ServerPlayerEntity player) {
            super.onStartedTrackingBy(player);
            this.bossBar.addPlayer(player);
        }
    </#if>

    <#if hasProcedure(data.whenMobIsHurt) || data.immuneToArrows || data.immuneToFallDamage
    || data.immuneToCactus || data.immuneToDrowning || data.immuneToLightning || data.immuneToPotions
    || data.immuneToPlayer || data.immuneToExplosion || data.immuneToTrident || data.immuneToAnvil
    || data.immuneToDragonBreath || data.immuneToWither>
        @Override
        	public boolean damage(DamageSource source, float amount) {
        	    <#if hasProcedure(data.whenMobIsHurt)>
		            double x = this.getX();
		            double y = this.getY();
		            double z = this.getZ();
                	Entity entity = this;
                	Entity sourceentity = source.getAttacker();
                	<@procedureOBJToCode data.whenMobIsHurt/>
                </#if>
                
                <#if data.immuneToArrows>
                	if (source.getSource() instanceof ArrowEntity)
                		return false;
                </#if>
                <#if data.immuneToPlayer>
                	if (source.getSource() instanceof PlayerEntity)
                		return false;
                </#if>
                <#if data.immuneToPotions>
                	if (source.getSource() instanceof PotionEntity)
                		return false;
                </#if>
                <#if data.immuneToFallDamage>
                	if (source == DamageSource.FALL)
                		return false;
                </#if>
                <#if data.immuneToCactus>
                	if (source == DamageSource.CACTUS)
                		return false;
                </#if>
                <#if data.immuneToDrowning>
                	if (source == DamageSource.DROWN)
                		return false;
                </#if>
                <#if data.immuneToLightning>
                	if (source == DamageSource.LIGHTNING_BOLT)
                		return false;
                </#if>
                <#if data.immuneToExplosion>
                	if (source.isExplosive())
                		return false;
                </#if>
                <#if data.immuneToTrident>
                	if (source.getName().equals("trident"))
                		return false;
                </#if>
                <#if data.immuneToAnvil>
                	if (source == DamageSource.ANVIL)
                		return false;
                </#if>
                <#if data.immuneToDragonBreath>
                	if (source == DamageSource.DRAGON_BREATH)
                		return false;
                </#if>
                <#if data.immuneToWither>
                	if (source == DamageSource.WITHER)
                		return false;
                	if (source.getName().equals("witherSkull"))
                		return false;
                </#if>
        		return super.damage(source, amount);
        	}
    </#if>

    public static void init() {
        FabricDefaultAttributeRegistry.register(ENTITY, ${name}Entity.createMobAttributes().add(EntityAttributes.GENERIC_MAX_HEALTH, ${data.health})
                .add(EntityAttributes.GENERIC_MOVEMENT_SPEED, ${data.movementSpeed})
                .add(EntityAttributes.GENERIC_ARMOR, ${data.armorBaseValue})
                .add(EntityAttributes.GENERIC_ATTACK_DAMAGE, ${data.attackStrength})

    <#if (data.knockbackResistance > 0)>
                .add(EntityAttributes.GENERIC_KNOCKBACK_RESISTANCE, ${data.knockbackResistance})
                </#if>

                <#if (data.attackKnockback > 0)>
                .add(EntityAttributes.GENERIC_ATTACK_KNOCKBACK, ${data.attackKnockback})
                </#if>


    <#if data.flyingMob>
                .add(EntityAttributes.GENERIC_FLYING_SPEED, 10)
                </#if>

    <#if data.aiBase == "Zombie">
    .add(EntityAttributes.ZOMBIE_SPAWN_REINFORCEMENTS)
    </#if>
                );

		<#if data.hasSpawnEgg>
        Registry.register(Registry.ITEM, ${JavaModName}.id("${registryname}_spawn_egg"),
                new SpawnEggItem(ENTITY, ${data.spawnEggBaseColor.getRGB()}, ${data.spawnEggDotColor.getRGB()}, new FabricItemSettings()<#if data.creativeTab??>.group(${data.creativeTab})<#else>.group(ItemGroup.MISC)</#if>));
        </#if>

        <#if data.spawnThisMob>
        BiomeModifications.create(new Identifier("${modid}", "${name?lower_case}_entity_spawn")).add(ModificationPhase.ADDITIONS,
                BiomeSelectors.<#if data.restrictionBiomes?has_content>includeByKey(<@biomeKeys data.restrictionBiomes/>)<#else>all()</#if>, ctx -> ctx.getSpawnSettings().addSpawn(${generator.map(data.mobSpawningType, "mobspawntypes")},
                        new SpawnSettings.SpawnEntry(ENTITY, ${data.spawningProbability}, ${data.minNumberOfMobsPerGroup}, ${data.maxNumberOfMobsPerGroup})));
        </#if>
    }

    <#if data.breedable>
        @Nullable
        @Override
        public PassiveEntity createChild(ServerWorld world, PassiveEntity entity) {
            return null;
        }
	</#if>

    <#if hasCondition(data.spawningCondition)>
    @Override
    public boolean canSpawn(WorldView w) {
        World world = getEntityWorld();
        return <@procedureOBJToConditionCode data.spawningCondition/>;
    }
    </#if>
}
<#-- @formatter:on -->