class PokeBattle_Battler
#===============================================================================
# Sleep
#===============================================================================
  def pbCanSleep?(showMessages,selfsleep=false,ignorestatus=false,move=nil,attacker=nil)
    return false if isFainted?
    if @battle.field.effects[PBEffects::ElectricTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!",pbThis)) if showMessages
      return false
    elsif @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with a protective mist!",pbThis)) if showMessages
      return false
    end
    if move !=nil && hasWorkingAbility(:OVERCOAT) && !move.effectsGrass?
      @battle.pbDisplayEffect(self)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move !=nil && pbHasType?(:GRASS) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move!=nil && hasWorkingItem(:SAFETYGOGGLES) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("{1} is not affected by {2} thanks to its Safety Goggles!",pbThis,move.name)) if showMessages
      return false
    end
    if !ignorestatus && status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1} is already asleep!",pbThis)) if showMessages
      return false
    end
    if !selfsleep && (status!=0 || effects[PBEffects::Substitute]>0)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if !hasWorkingAbility(:SOUNDPROOF) && !attacker.nil? && !attacker.hasBypassingAbility
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          @battle.pbDisplay(_INTL("But {1} can't sleep in an uproar!",pbThis(true))) if showMessages
          return false
        end
      end 
    end
    if hasWorkingAbility(:VITALSPIRIT) ||
       hasWorkingAbility(:INSOMNIA) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      if !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        abilityname=PBAbilities.getName(self.ability)
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true),abilityname)) if showMessages
        return false
      end
    end
    if hasWorkingAbility(:SWEETVEIL)
      if !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        abilityname=PBAbilities.getName(self.ability)
        if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of sweetness!",pbThis)) if showMessages
        else
          @battle.pbDisplay(_INTL("{1} stayed awake using its {2}!",pbThis,abilityname)) if showMessages
        end
        return false
      end
    end
    if pbPartner.hasWorkingAbility(:SWEETVEIL)
        if !attacker.hasBypassingAbility
          @battle.pbDisplayEffect(pbPartner)
         abilityname=PBAbilities.getName(pbPartner.ability)
         if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of sweetness!",pbThis)) if showMessages
         else
          @battle.pbDisplay(_INTL("{1} stayed awake using its partner's {2}!",pbThis,abilityname)) if showMessages
         end
         return false
      end
    end
    if !selfsleep && pbOwnSide.effects[PBEffects::Safeguard]>0 &&
      (attacker==nil || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1} is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanSleepYawn?(attacker=nil,showMessages=false)
    return false if status!=0
    if !hasWorkingAbility(:SOUNDPROOF) && !attacker.nil? && !attacker.hasBypassingAbility
      for i in 0...4
        return false if @battle.battlers[i].effects[PBEffects::Uproar]>0
      end
    end
    if @battle.field.effects[PBEffects::ElectricTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!",pbThis)) if showMessages
      return false
    elsif @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with a protective mist!",pbThis)) if showMessages
      return false
    end
    if hasWorkingAbility(:VITALSPIRIT) ||
       hasWorkingAbility(:INSOMNIA) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      if !@battle.pbCheckOpposingBypassingAbility(self)
        @battle.pbDisplayEffect(self)
        abilityname=PBAbilities.getName(self.ability)
        if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
        else
          @battle.pbDisplay(_INTL("{1} stayed awake using its {2}!",pbThis,abilityname)) if showMessages
        end
        return false
      end
    end
    if hasWorkingAbility(:SWEETVEIL)
       if !@battle.pbCheckOpposingBypassingAbility(self)
         @battle.pbDisplayEffect(pbPartner)
         abilityname=PBAbilities.getName(self.ability)
         if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of sweetness!",pbThis)) if showMessages
         else
           @battle.pbDisplay(_INTL("{1} stayed awake using its {2}!",pbThis,abilityname)) if showMessages
         end
         return false
       end
    end
    if pbPartner.hasWorkingAbility(:SWEETVEIL)
       if !@battle.pbCheckOpposingBypassingAbility(self)
         @battle.pbDisplayEffect(pbPartner)
         abilityname=PBAbilities.getName(pbPartner.ability)
         if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of sweetness!",pbThis)) if showMessages
         else
           @battle.pbDisplay(_INTL("{1} stayed awake using its partner's {2}!",pbThis,abilityname)) if showMessages
         end
         return false
       end
    end
    return true
  end

  def pbSleep
    self.status=PBStatuses::SLEEP
    self.statusCount=2+@battle.pbRandom(3)
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
    PBDebug.log("[#{pbThis}: fell asleep (#{self.statusCount} turns)]")
  end

  def pbSleepSelf(duration=-1)
    self.status=PBStatuses::SLEEP
    if duration>0
      self.statusCount=duration
    else
      self.statusCount=2+@battle.pbRandom(3)
    end
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
    PBDebug.log("[#{pbThis}: made itself fall asleep (#{self.statusCount} turns)]")
  end

#===============================================================================
# Poison
#===============================================================================
 def pbCanPoison?(showMessages,move=nil,attacker=nil)
    return false if isFainted?
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with a protective mist!",pbThis(true))) if showMessages
      return false
    end
    if move !=nil && hasWorkingAbility(:OVERCOAT) && !move.effectsGrass?
      @battle.pbDisplayEffect(self)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move !=nil && pbHasType?(:GRASS) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move!=nil && hasWorkingItem(:SAFETYGOGGLES) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("{1} is not affected by {2} thanks to its Safety Goggles!",pbThis,move.name)) if showMessages
      return false
    end
    if status==PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} is already poisoned.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:POISON) || pbHasType?(:STEEL)) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end   
    if hasWorkingAbility(:IMMUNITY) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      if !attacker.nil? && !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
        else
          @battle.pbDisplay(_INTL("{1}'s {2} prevents poisoning!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
      (attacker==nil || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1} is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanPoisonSynchronize?(opponent)
    return false if isFainted?
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      return false
    end
    if (pbHasType?(:POISON) || pbHasType?(:STEEL)) && !hasWorkingItem(:RINGTARGET)
      if EFFECTMESSAGES
        @battle.pbDisplay(_INTL("It doesn't affect {1}..",pbThis(true)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
      end
      return false
    end   
    return false if self.status!=0
    if hasWorkingAbility(:IMMUNITY) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplayEffect(self)
      if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
           pbThis,PBAbilities.getName(self.ability),
           opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      end
      return false
    end
    return true
  end

  def pbCanPoisonSpikes?
    return false if isFainted?
    return false if self.status!=0
    return false if pbHasType?(:POISON) || pbHasType?(:STEEL)
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      return false
    end
    return false if hasWorkingAbility(:IMMUNITY) && !@battle.pbCheckOpposingBypassingAbility(self)
    return false if hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY && !@battle.pbCheckOpposingBypassingAbility(self)
    return false if pbOwnSide.effects[PBEffects::Safeguard]>0
    return true
  end
  
  def pbPoison(attacker,toxic=false)
    self.status=PBStatuses::POISON
    if toxic
      self.statusCount=1
      self.effects[PBEffects::Toxic]=0
    else
      self.statusCount=0
    end
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::POISON
    end
    @battle.pbCommonAnimation("Poison",self,nil)
    if toxic
      PBDebug.log("[#{pbThis}: was badly poisoned]")
    else
      PBDebug.log("[#{pbThis}: was poisoned")
    end
  end

#===============================================================================
# Burn
#===============================================================================
 def pbCanBurn?(showMessages,move=nil,attacker=nil)
    return false if isFainted?
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with a protective mist!",pbThis(true))) if showMessages
      return false
    end
    if move !=nil && hasWorkingAbility(:OVERCOAT) && !move.effectsGrass?
      @battle.pbDisplayEffect(self)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move !=nil && pbHasType?(:GRASS) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move!=nil && hasWorkingItem(:SAFETYGOGGLES) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("{1} is not affected by {2} thanks to its Safety Goggles!",pbThis,move.name)) if showMessages
      return false
    end
    if self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
       return false
    end
    if hasWorkingAbility(:WATERVEIL) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      if !attacker.nil? && !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
        else
          @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
      (attacker==nil || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1} is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBurnFromFireMove?(move,showMessages,attacker=nil) # Use for status moves only
    return false if isFainted?
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with a protective mist!",pbThis(true))) if showMessages
      return false
    end
    if self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if hasWorkingAbility(:FLASHFIRE) && isConst?(move.type,PBTypes,:FIRE)
      if !attacker.nil? && !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        if EFFECTMESSAGES
          if !@effects[PBEffects::FlashFire]
            @effects[PBEffects::FlashFire]=true
            @battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",pbThis))
          else
            @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true)))
          end
        else
          if !@effects[PBEffects::FlashFire]
            @effects[PBEffects::FlashFire]=true
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",pbThis,PBAbilities.getName(self.ability)))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",pbThis,PBAbilities.getName(self.ability),move.name))
          end
        end
        return false
      end
    end
    if hasWorkingAbility(:WATERVEIL) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      if !attacker.nil? && !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
        else
          @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
      (attacker==nil || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1} is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBurnSynchronize?(opponent)
    return false if isFainted?
    return false if self.status!=0
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      return false
    end
    if hasWorkingAbility(:FLASHFIRE)
      if opponent.nil? && opponent.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        if EFFECTMESSAGES
          if !@effects[PBEffects::FlashFire]
            @effects[PBEffects::FlashFire]=true
            @battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",pbThis))
          else
            @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true)))
          end
        else
          if !@effects[PBEffects::FlashFire]
            @effects[PBEffects::FlashFire]=true
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",pbThis,PBAbilities.getName(self.ability)))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",pbThis,PBAbilities.getName(self.ability),move.name))
          end
        end
        return false
      end
    end
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
       if EFFECTMESSAGES
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true)))
       else
         @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       end
       return false
    end   
    if hasWorkingAbility(:WATERVEIL) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplayEffect(self)
      if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
           pbThis,PBAbilities.getName(self.ability),
           opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      end
      return false
    end
    return true
  end

  def pbBurn(attacker)
    self.status=PBStatuses::BURN
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::BURN
    end
    @battle.pbCommonAnimation("Burn",self,nil)
    PBDebug.log("[#{pbThis}: was burned")
  end

#===============================================================================
# Paralyze
#===============================================================================
  def pbCanParalyze?(showMessages, move=nil, attacker=nil)
    return false if isFainted?
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with a protective mist!",pbThis(true))) if showMessages
      return false
    end
    if status==PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} is already paralyzed!",pbThis)) if showMessages
      return false
    end
    if move !=nil && hasWorkingAbility(:OVERCOAT) && !move.effectsGrass?
      @battle.pbDisplayEffect(self)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move !=nil && pbHasType?(:GRASS) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move!=nil && hasWorkingItem(:SAFETYGOGGLES) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("{1} is not affected by {2} thanks to its Safety Goggles!",pbThis,move.name)) if showMessages
      return false
    end
    if pbHasType?(:ELECTRIC) && !self.hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis))  if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if hasWorkingAbility(:LIMBER) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      if !attacker.nil? && !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
        else
          @battle.pbDisplay(_INTL("{1}'s {2} prevents paralysis!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
      (attacker==nil || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1} is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanParalyzeSynchronize?(opponent)
    return false if self.status!=0
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      return false
    end
    if pbHasType?(:ELECTRIC) && !self.hasWorkingItem(:RINGTARGET)
      if EFFECTMESSAGES
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
      end
      return false
    end
    if hasWorkingAbility(:LIMBER) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplayEffect(self)
      if EFFECTMESSAGES
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
           pbThis,PBAbilities.getName(self.ability),
           opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      end
      return false
    end
    return true
  end

  def pbParalyze(attacker)
    self.status=PBStatuses::PARALYSIS
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::PARALYSIS
    end
    @battle.pbCommonAnimation("Paralysis",self,nil)
    PBDebug.log("[#{pbThis}: was paralyzed")
  end

#===============================================================================
# Freeze
#===============================================================================
  def pbCanFreeze?(showMessages,move=nil,attacker=nil)
    return false if isFainted?
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !isAirborne?
      @battle.pbDisplay(_INTL("{1} surrounds itself with a protective mist!",pbThis(true))) if showMessages
      return false
    end
    if move !=nil && hasWorkingAbility(:OVERCOAT) && !move.effectsGrass?
      @battle.pbDisplayEffect(self)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move !=nil && pbHasType?(:GRASS) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis)) if showMessages
      return false
    end
    if move!=nil && hasWorkingItem(:SAFETYGOGGLES) && !move.effectsGrass?
      @battle.pbDisplay(_INTL("{1} is not affected by {2} thanks to its Safety Goggles!",pbThis,move.name)) if showMessages
      return false
    end
    if @battle.pbWeather==PBWeather::SUNNYDAY || self.status!=0 ||
       hasWorkingAbility(:MAGMAARMOR) ||
       pbOwnSide.effects[PBEffects::Safeguard]>0 ||
       effects[PBEffects::Substitute]>0 ||
       (pbHasType?(:ICE) && !hasWorkingItem(:RINGTARGET))
      if attacker!=nil && !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        return false
      end
    end
    return true
  end

  def pbFreeze
    self.status=PBStatuses::FROZEN
    self.statusCount=0
    pbCancelMoves
    @battle.pbCommonAnimation("Frozen",self,nil)
    PBDebug.log("[#{pbThis}: was frozen")
  end

#===============================================================================
# Generalised status displays
#===============================================================================
  def pbContinueStatus(showAnim=true)
    case self.status
    when PBStatuses::SLEEP
      @battle.pbCommonAnimation("Sleep",self,nil)
      @battle.pbDisplay(_INTL("{1} is fast asleep.",pbThis))
    when PBStatuses::POISON
      @battle.pbCommonAnimation("Poison",self,nil)
      @battle.pbDisplay(_INTL("{1} is hurt by poison!",pbThis))
    when PBStatuses::BURN
      @battle.pbCommonAnimation("Burn",self,nil)
      @battle.pbDisplay(_INTL("{1} is hurt by its burn!",pbThis))
    when PBStatuses::PARALYSIS
      @battle.pbCommonAnimation("Paralysis",self,nil)
      @battle.pbDisplay(_INTL("{1} is paralyzed!  It can't move!",pbThis)) 
    when PBStatuses::FROZEN
      @battle.pbCommonAnimation("Frozen",self,nil)
      @battle.pbDisplay(_INTL("{1} is frozen solid!",pbThis))
    end
  end

  def pbCureStatus(showMessages=true)
    oldstatus=self.status
    if self.status==PBStatuses::SLEEP
      self.effects[PBEffects::Nightmare]=false
    end
    self.status=0
    self.statusCount=0
    if showMessages
      case oldstatus
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} woke up!",pbThis))
      when PBStatuses::POISON
      when PBStatuses::BURN
      when PBStatuses::PARALYSIS
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} thawed out!",pbThis))
      end
    end
    PBDebug.log("[#{pbThis}: status problem was cured]")
  end

#===============================================================================
# Confuse
#===============================================================================
  def pbCanConfuse?(showMessages, attacker=nil)
    return false if isFainted?
    if effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if hasWorkingAbility(:OWNTEMPO) && !attacker.hasBypassingAbility
      @battle.pbDisplayEffect(self)
      if EFFECTMESSAGES
        @battle.pbDisplay(_INTL("{1} doesn't become confused!",pbThis(true))) if showMessages
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      end
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
      (attacker==nil || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1} is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanConfuseSelf?(showMessages)
    return false if isFainted?
    if effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if hasWorkingAbility(:OWNTEMPO) && !attacker.hasBypassingAbility
      @battle.pbDisplayEffect(self)
      if EFFECTMESSAGES
        @battle.pbDisplay(_INTL("{1} doesn't become confused!",pbThis(true))) if showMessages
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      end
      return false
    end
    return true
  end

  def pbConfuseSelf
    if @effects[PBEffects::Confusion]==0 && !hasWorkingAbility(:OWNTEMPO)
      @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",self,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
      PBDebug.log("[#{pbThis}: became confused (#{self.statusCount} turns)]")
    end
  end

  def pbContinueConfusion
    @battle.pbCommonAnimation("Confusion",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is confused!",pbThis))
  end

  def pbCureConfusion(showMessages=true)
    @effects[PBEffects::Confusion]=0
    @battle.pbDisplay(_INTL("{1} snapped out of confusion!",pbThis)) if showMessages
    PBDebug.log("[#{pbThis}: cured its confusion]")
  end

#===============================================================================
# Attraction
#===============================================================================
  def pbCanAttract?(attacker,showMessages=true)
    return false if isFainted?
    return false if !attacker
    if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    agender=attacker.gender
    ogender=self.gender
    if agender==2 || ogender==2 || agender==ogender
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if hasWorkingAbility(:OBLIVIOUS) && !attacker.hasBypassingAbility
      @battle.pbDisplayEffect(self)
      if EFFECTMESSAGES
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",pbThis,
           PBAbilities.getName(self.ability))) if showMessages
      end
      return false
    end
    return true
  end

  def pbAnnounceAttract(seducer)
    @battle.pbCommonAnimation("Attract",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is in love with {2}!",
       pbThis,seducer.pbThis(true)))
  end

  def pbContinueAttract
    @battle.pbDisplay(_INTL("{1} is immobilized by love!",pbThis)) 
  end

#===============================================================================
# Increase stat stages
#===============================================================================
  def pbTooHigh?(stat)
    return @stages[stat]>=6
  end

  def pbCanIncreaseStatStage?(stat,showMessages=false,attacker=nil)
    return false if isFainted?
    if pbTooHigh?(stat)
      if showMessages
        @battle.pbDisplay(_INTL("{1}'s Attack won't go any higher!",pbThis)) if stat==PBStats::ATTACK
        @battle.pbDisplay(_INTL("{1}'s Defense won't go any higher!",pbThis)) if stat==PBStats::DEFENSE
        @battle.pbDisplay(_INTL("{1}'s Speed won't go any higher!",pbThis)) if stat==PBStats::SPEED
        @battle.pbDisplay(_INTL("{1}'s Special Attack won't go any higher!",pbThis)) if stat==PBStats::SPATK
        @battle.pbDisplay(_INTL("{1}'s Special Defense won't go any higher!",pbThis)) if stat==PBStats::SPDEF
        @battle.pbDisplay(_INTL("{1}'s evasiveness won't go any higher!",pbThis)) if stat==PBStats::EVASION
        @battle.pbDisplay(_INTL("{1}'s accuracy won't go any higher!",pbThis)) if stat==PBStats::ACCURACY
      end
      return false
    end
    return true
  end

  def pbIncreaseStatBasic(stat,increment,opponent=nil,contrary=false)
    if !contrary && hasWorkingAbility(:CONTRARY) && (!opponent || !opponent.hasBypassingAbility)
      if pbCanReduceStatStage?(stat,true)
        pbReduceStat(stat,increment,true,true,false,opponent,true,false)
        return false
      end
    end
    if opponent==nil || !(opponent.hasBypassingAbility)
      if hasWorkingAbility(:SIMPLE)
        @battle.pbDisplayEffect(self)
        increment*=2 
      end
    end
    PBDebug.log("[#{pbThis}: stat #{getConstantName(PBStats,stat)} rose by #{increment} stage(s) (was #{@stages[stat]}, now #{[@stages[stat]+increment,6].min}]")
    @stages[stat]+=increment
    @stages[stat]=6 if @stages[stat]>6
    return increment
  end

  def pbIncreaseStat(stat,increment,showMessages,upanim=true,opponent=nil,contrary=false)
    if !contrary && hasWorkingAbility(:CONTRARY) && (!opponent || !opponent.hasBypassingAbility)
      @battle.pbDisplayEffect(self)
      if pbCanReduceStatStage?(stat,showMessages)
        pbReduceStat(stat,increment,showMessages,upanim,false,opponent,true,false)
        return true
      else
        return false
      end
    end
    arrStatTexts=[]
    if stat==PBStats::ATTACK
      arrStatTexts=[_INTL("{1}'s Attack rose!",pbThis),
         _INTL("{1}'s Attack rose sharply!",pbThis),
         _INTL("{1}'s Attack rose drastically!",pbThis),
         _INTL("{1}'s Attack went way up!",pbThis)]
    elsif stat==PBStats::DEFENSE
      arrStatTexts=[_INTL("{1}'s Defense rose!",pbThis),
         _INTL("{1}'s Defense rose sharply!",pbThis),
         _INTL("{1}'s Defense rose drastically!",pbThis),
         _INTL("{1}'s Defense went way up!",pbThis)]
    elsif stat==PBStats::SPEED
      arrStatTexts=[_INTL("{1}'s Speed rose!",pbThis),
         _INTL("{1}'s Speed rose sharply!",pbThis),
         _INTL("{1}'s Speed rose drastically!",pbThis),
         _INTL("{1}'s Speed went way up!",pbThis)]
    elsif stat==PBStats::SPATK
      arrStatTexts=[_INTL("{1}'s Special Attack rose!",pbThis),
         _INTL("{1}'s Special Attack rose sharply!",pbThis),
         _INTL("{1}'s Special Attack rose drastically!",pbThis),
         _INTL("{1}'s Special Attack went way up!",pbThis)]
    elsif stat==PBStats::SPDEF
      arrStatTexts=[_INTL("{1}'s Special Defense rose!",pbThis),
         _INTL("{1}'s Special Defense rose sharply!",pbThis),
         _INTL("{1}'s Special Defense rose drastically!",pbThis),
         _INTL("{1}'s Special Defense went way up!",pbThis)]
    elsif stat==PBStats::EVASION
      arrStatTexts=[_INTL("{1}'s evasiveness rose!",pbThis),
         _INTL("{1}'s evasiveness rose sharply!",pbThis),
         _INTL("{1}'s evasiveness rose drastically!",pbThis),
         _INTL("{1}'s evasiveness went way up!",pbThis)]
    elsif stat==PBStats::ACCURACY
      arrStatTexts=[_INTL("{1}'s accuracy rose!",pbThis),
         _INTL("{1}'s accuracy rose sharply!",pbThis),
         _INTL("{1}'s accuracy rose drastically!",pbThis),
         _INTL("{1}'s accuracy went way up!",pbThis)]
    else
      return false
    end
    if pbCanIncreaseStatStage?(stat,showMessages)
      increment=pbIncreaseStatBasic(stat,increment,opponent,contrary)
      return false if !increment.is_a?(Numeric)
      @battle.pbCommonAnimation("StatUp",self,nil) if upanim
        if showMessages
        if increment>3
          @battle.pbDisplay(arrStatTexts[3])
        elsif increment==3
          @battle.pbDisplay(arrStatTexts[2])
        elsif increment==2
          @battle.pbDisplay(arrStatTexts[1])
        else
          @battle.pbDisplay(arrStatTexts[0])
        end
      end
      return true
    end
    return false
  end

#===============================================================================
# Decrease stat stages
#===============================================================================
  def pbTooLow?(stat)
    return @stages[stat]<=-6
  end

  # Tickle (04A) and Memento (0E2) can't use this, but replicate it instead.
  # (Reason is they lower more than 1 stat independently, and therefore could
  # show certain messages twice which is undesirable.)
  def pbCanReduceStatStage?(stat,showMessages=false,selfreduce=false,opponent=nil)
    return false if isFainted?
    if !selfreduce
      if effects[PBEffects::Substitute]>0
        @battle.pbDisplay(_INTL("But it failed!")) if showMessages
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showMessages
        return false
      end
      if (hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE)) #Need Moldbreaker here
        if opponent == nil || !(opponent.hasBypassingAbility)
          @battle.pbDisplayEffect(self) if showMessages
          if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s stats were not lowered!",pbThis)) if showMessages
          else
            abilityname=PBAbilities.getName(self.ability)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
          end
          return false
        end
      end
      if stat==PBStats::ATTACK && hasWorkingAbility(:HYPERCUTTER)
        if opponent == nil || !(opponent.hasBypassingAbility)
          @battle.pbDisplayEffect(self) if showMessages
          if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s Attack was not lowered!",pbThis)) if showMessages
          else
            abilityname=PBAbilities.getName(self.ability)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",pbThis,abilityname)) if showMessages
          end
          return false
        end
      end
      if stat==PBStats::DEFENSE && hasWorkingAbility(:BIGPECKS)
        if opponent == nil || !(opponent.hasBypassingAbility)
          @battle.pbDisplayEffect(self) if showMessages
          if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s Defense was not lowered!",pbThis)) if showMessages
          else
            abilityname=PBAbilities.getName(self.ability)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents Defense loss!",pbThis,abilityname)) if showMessages
          end
          return false
        end
      end
      if stat==PBStats::ACCURACY && hasWorkingAbility(:KEENEYE)
        if opponent == nil || !(opponent.hasBypassingAbility)
          @battle.pbDisplayEffect(self) if showMessages
          if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s accuracy was not lowered!",pbThis)) if showMessages
          else
            abilityname=PBAbilities.getName(self.ability)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents accuracy loss!",pbThis,abilityname)) if showMessages
          end
          return false
        end
      end
    end
    if pbTooLow?(stat)
      if showMessages
        @battle.pbDisplay(_INTL("{1}'s Attack won't go any lower!",pbThis)) if stat==PBStats::ATTACK
        @battle.pbDisplay(_INTL("{1}'s Defense won't go any lower!",pbThis)) if stat==PBStats::DEFENSE
        @battle.pbDisplay(_INTL("{1}'s Speed won't go any lower!",pbThis)) if stat==PBStats::SPEED
        @battle.pbDisplay(_INTL("{1}'s Special Attack won't go any lower!",pbThis)) if stat==PBStats::SPATK
        @battle.pbDisplay(_INTL("{1}'s Special Defense won't go any lower!",pbThis)) if stat==PBStats::SPDEF
        @battle.pbDisplay(_INTL("{1}'s evasiveness won't go any lower!",pbThis)) if stat==PBStats::EVASION
        @battle.pbDisplay(_INTL("{1}'s accuracy won't go any lower!",pbThis)) if stat==PBStats::ACCURACY
      end
      return false
    end
    return true
  end

  def pbReduceStatBasic(stat,increment,attacker=nil,contrary=false,flowerveil=true)
    if !contrary && hasWorkingAbility(:CONTRARY) && (!attacker || !(attacker.hasBypassingAbility))
      @battle.pbDisplayEffect(self)
      if pbCanIncreaseStatStage?(stat,true,attacker)
        pbIncreaseStat(stat,increment,true,true,attacker,true)
        return false
      end
    end
    if flowerveil
      flowerVeilPoke=@battle.pbCheckSideAbility(:FLOWERVEIL,self)
      if flowerVeilPoke != nil && pbHasType?(:GRASS)
        if attacker == nil || !(attacker.hasBypassingAbility)
          @battle.pbDisplayEffect(flowerVeilPoke)
          @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of petals!",pbThis))
          return 0
        end
      end
    end
    if attacker == nil || !(attacker.hasBypassingAbility)
      if hasWorkingAbility(:SIMPLE)
        @battle.pbDisplayEffect(self)
        increment*=2 
      end
    end
    PBDebug.log("[#{pbThis}: stat #{getConstantName(PBStats,stat)} fell by #{increment} stage(s) (was #{@stages[stat]}, now #{[@stages[stat]-increment,-6].max}]")
    @stages[stat]-=increment
    @stages[stat]=-6 if @stages[stat]<-6
    return increment
  end

  def pbReduceStat(stat,increment,showMessages,downanim=true,selfreduce=false,attacker=nil,contrary=false,flowerveil=true)
    if !contrary && hasWorkingAbility(:CONTRARY) && (!attacker || !(attacker.hasBypassingAbility))
      @battle.pbDisplayEffect(self)
      if pbCanIncreaseStatStage?(stat,showMessages,attacker)
        pbIncreaseStat(stat,increment,true,true,attacker,true)
        return true
      else
        return false
      end
    end
    #Flower Veil
    if flowerveil
      flowerVeilPoke=@battle.pbCheckSideAbility(:FLOWERVEIL,self)
      if flowerVeilPoke != nil && pbHasType?(:GRASS) && !selfreduce
        if attacker == nil || !(attacker.hasBypassingAbility)
          @battle.pbDisplayEffect(flowerVeilPoke) if showMessages
          @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of petals!",pbThis))
          return false
        end
      end
    end
    arrStatTexts=[]
    if stat==PBStats::ATTACK
      arrStatTexts=[_INTL("{1}'s Attack fell!",pbThis),
         _INTL("{1}'s Attack harshly fell!",pbThis)]
    elsif stat==PBStats::DEFENSE
      arrStatTexts=[_INTL("{1}'s Defense fell!",pbThis),
         _INTL("{1}'s Defense harshly fell!",pbThis)]
    elsif stat==PBStats::SPEED
      arrStatTexts=[_INTL("{1}'s Speed fell!",pbThis),
         _INTL("{1}'s Speed harshly fell!",pbThis)]
    elsif stat==PBStats::SPATK
      arrStatTexts=[_INTL("{1}'s Special Attack fell!",pbThis),
         _INTL("{1}'s Special Attack harshly fell!",pbThis)]
    elsif stat==PBStats::SPDEF
      arrStatTexts=[_INTL("{1}'s Special Defense fell!",pbThis),
         _INTL("{1}'s Special Defense harshly fell!",pbThis)]
    elsif stat==PBStats::EVASION
      arrStatTexts=[_INTL("{1}'s evasiveness fell!",pbThis),
         _INTL("{1}'s evasiveness harshly fell!",pbThis)]
    elsif stat==PBStats::ACCURACY
      arrStatTexts=[_INTL("{1}'s accuracy fell!",pbThis),
         _INTL("{1}'s accuracy harshly fell!",pbThis)]
    else
      return false
    end
    if pbCanReduceStatStage?(stat,showMessages,selfreduce,attacker)
      increment=pbReduceStatBasic(stat,increment,attacker,contrary)
      return false if !increment.is_a?(Numeric)
      @battle.pbCommonAnimation("StatDown",self,nil) if downanim
      if increment>=2
        @battle.pbDisplay(arrStatTexts[1]) if showMessages
      else
        @battle.pbDisplay(arrStatTexts[0]) if showMessages
      end
      if !selfreduce && hasWorkingAbility(:COMPETITIVE) #JV
          @battle.pbDisplayEffect(self) if showMessages
          pbIncreaseStat(PBStats::SPATK,2,false)
          if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s Special Attack sharply rose!",pbThis))
          else
            @battle.pbDisplay(_INTL("Competitive sharply raised {1}'s Special Attack!", pbThis(true))) if showMessages
          end
      end
      if !selfreduce && hasWorkingAbility(:DEFIANT) #JV and Joeyhugg 
          @battle.pbDisplayEffect(self) if showMessages
          pbIncreaseStat(PBStats::ATTACK,2,false)
          if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s Attack sharply rose!",pbThis))
          else
            @battle.pbDisplay(_INTL("Defiant sharply raised {1}'s Attack!", pbThis(true))) if showMessages
          end
      end
      return true
    end
    return false
  end

  def pbReduceAttackStatStageIntimidate(opponent)
    return false if isFainted?
    return false if effects[PBEffects::Substitute]>0
    if hasWorkingAbility(:CONTRARY)
      @battle.pbDisplayEffect(self)
      if pbCanIncreaseStatStage?(PBStats::ATTACK)
        pbIncreaseStat(PBStats::ATTACK,1,true,true,nil,true)
        @battle.pbDisplay(_INTL("{1}'s Contrary raised its Attack!",pbThis)) if !EFFECTMESSAGES
        return true
      else
        return false
      end
    end
    if @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true)))
      return false
    end
    if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE) ||
       hasWorkingAbility(:HYPERCUTTER)
      if !attacker.hasBypassingAbility
        @battle.pbDisplayEffect(self)
        if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s stats were not lowered!",pbThis))
        else
          abilityname=PBAbilities.getName(self.ability)
          oppabilityname=PBAbilities.getName(attacker.ability)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityname,attacker.pbThis(true),oppabilityname))
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis))
      return false
    end
    #Flower Veil
    flowerVeilPoke=@battle.pbCheckSideAbility(:FLOWERVEIL,self)
    if flowerVeilPoke != nil && pbHasType?(:GRASS)
      @battle.pbDisplayEffect(flowerVeilPoke)
      @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of petals!",pbThis))
      return false
    end
    if pbCanReduceStatStage?(PBStats::ATTACK,false)
      pbReduceStatBasic(PBStats::ATTACK,1)
      oppabilityname=PBAbilities.getName(opponent.ability)
      @battle.pbCommonAnimation("StatDown",self,nil)
      if EFFECTMESSAGES
        @battle.pbDisplay(_INTL("{1}'s Attack fell!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} cuts {3}'s Attack!",opponent.pbThis,
           oppabilityname,pbThis(true)))
      end
      if hasWorkingAbility(:COMPETITIVE) #JV
          @battle.pbDisplayEffect(self)
          pbIncreaseStat(PBStats::SPATK,2,false)
          if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s Special Attack sharply rose!",pbThis))
          else
            @battle.pbDisplay(_INTL("Competitive sharply raised {1}'s Special Attack!", pbThis(true)))
          end
      end
      if hasWorkingAbility(:DEFIANT) #JV and Joeyhugg 
          @battle.pbDisplayEffect(self)
          pbIncreaseStat(PBStats::ATTACK,2,false)
          if EFFECTMESSAGES
            @battle.pbDisplay(_INTL("{1}'s Attack sharply rose!",pbThis))
          else
            @battle.pbDisplay(_INTL("Defiant sharply raised {1}'s Attack!", pbThis(true)))
          end
      end   
      return true
    end
    return false
  end
end