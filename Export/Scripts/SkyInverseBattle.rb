def pbWildBattle(species,level,variable=nil,canescape=true,canlose=false,skybattle=false,inverse=false)
 if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
   if $Trainer.pokemonCount>0
     Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
   end
   pbSet(variable,1)
   $PokemonGlobal.nextBattleBGM=nil
   $PokemonGlobal.nextBattleME=nil
   $PokemonGlobal.nextBattleBack=nil
   return true
 end
 # Sky battle eligibility for player
 if skybattle
   count=0
   for poke in $Trainer.party
     count+=1 if pbCanSkyBattle?(poke)
   end
   if count==0
     Kernel.pbMessage(_INTL("You don't have any eligible pokemon for a sky battle"))
     return false
   end
 end
 if species.is_a?(String) || species.is_a?(Symbol)
   species=getID(PBSpecies,species)
 end
 handled=[nil]
 Events.onWildBattleOverride.trigger(nil,species,level,handled)
 if handled[0]!=nil
   return handled[0]
 end
 currentlevels=[]
 for i in $Trainer.party
   currentlevels.push(i.level)
 end
 genwildpoke=pbGenerateWildPokemon(species,level)
 Events.onStartBattle.trigger(nil,genwildpoke)
 if skybattle && !pbCanSkyBattle?(genwildpoke)
   Kernel.pbMessage(_INTL("This pokemon can't fight in a sky battle!"))
   return false
 end
 scene=pbNewBattleScene
 battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke],$Trainer,nil,skybattle,inverse)
 battle.internalbattle=true
 battle.cantescape=!canescape
 pbPrepareBattle(battle)
 decision=0
 pbBattleAnimation(pbGetWildBattleBGM(species)) { 
    pbSceneStandby {
       decision=battle.pbStartBattle(canlose)
    }
    for i in $Trainer.party; (i.makeUnmega rescue nil); end
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
        i.makeUnmega rescue nil
      end
    end
    if decision==2 || decision==5 # if loss or draw
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
#       else
#         $game_system.bgm_unpause
#         $game_system.bgs_unpause
#         Kernel.pbStartOver
      end
    end
    Events.onEndBattle.trigger(nil,decision,canlose)
 }
 Input.update
 pbSet(variable,decision)
 Events.onWildBattleEnd.trigger(nil,species,level,decision)
 return (decision!=2)
end

def pbDoubleWildBattle(species1,level1,species2,level2,variable=nil,canescape=true,canlose=false,skybattle=false,inverse=false)
 if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
   if $Trainer.pokemonCount>0
     Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
   end
   pbSet(variable,1)
   $PokemonGlobal.nextBattleBGM=nil
   $PokemonGlobal.nextBattleME=nil
   $PokemonGlobal.nextBattleBack=nil
   return true
 end
 if species1.is_a?(String) || species1.is_a?(Symbol)
   species1=getID(PBSpecies,species1)
 end
 if species2.is_a?(String) || species2.is_a?(Symbol)
   species2=getID(PBSpecies,species2)
 end
 currentlevels=[]
 for i in $Trainer.party
   currentlevels.push(i.level)
 end
 genwildpoke=pbGenerateWildPokemon(species1,level1)
 genwildpoke2=pbGenerateWildPokemon(species2,level2)
 Events.onStartBattle.trigger(nil,genwildpoke)
 if skybattle && (!pbCanSkyBattle?(genwildpoke) || !pbCanSkyBattle?(genwildpoke2))
   Kernel.pbMessage(_INTL("These pokemon can't fight in a sky battle!"))
   return false
 end
 scene=pbNewBattleScene
 if $PokemonGlobal.partner
   othertrainer=PokeBattle_Trainer.new(
      $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
   othertrainer.id=$PokemonGlobal.partner[2]
   othertrainer.party=$PokemonGlobal.partner[3]
   combinedParty=[]
   for i in 0...$Trainer.party.length
     combinedParty[i]=$Trainer.party[i]
   end
   for i in 0...othertrainer.party.length
     combinedParty[6+i]=othertrainer.party[i]
   end
   battle=PokeBattle_Battle.new(scene,combinedParty,[genwildpoke,genwildpoke2],
      [$Trainer,othertrainer],nil,skybattle,inverse)
   battle.fullparty1=true
 else
   battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke,genwildpoke2],
      $Trainer,nil,skybattle,inverse)
   battle.fullparty1=false
 end
 battle.internalbattle=true
 battle.doublebattle=battle.pbDoubleBattleAllowed?()
 battle.cantescape=!canescape
 pbPrepareBattle(battle)
 decision=0
 pbBattleAnimation(pbGetWildBattleBGM(species1)) { 
    pbSceneStandby {
       decision=battle.pbStartBattle(canlose)
    }
    for i in $Trainer.party; (i.makeUnmega rescue nil); end
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
        i.makeUnmega rescue nil
      end
    end
    if decision==2 || decision==5
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
#       else
#         $game_system.bgm_unpause
#         $game_system.bgs_unpause
#         Kernel.pbStartOver
      end
    end
    Events.onEndBattle.trigger(nil,decision,canlose)
 }
 Input.update
 pbSet(variable,decision)
 return (decision!=2 && decision!=5)
end


def pbTrainerBattle(trainerid,trainername,endspeech,
                   doublebattle=false,trainerparty=0,canlose=false,variable=nil,
                   skybattle=false,inverse=false)
 if $Trainer.pokemonCount==0
   Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
   return false
 end
 # Sky battle eligibility for player
 if skybattle
   count=0
   for poke in $Trainer.party
     count+=1 if pbCanSkyBattle?(poke)
   end
   if count==0
     Kernel.pbMessage(_INTL("You don't have any eligible pokemon for a sky battle"))
     return false
   end
 end
 if !$PokemonTemp.waitingTrainer && $Trainer.ablePokemonCount>1 &&
    pbMapInterpreterRunning?
   thisEvent=pbMapInterpreter.get_character(0)
   triggeredEvents=$game_player.pbTriggeredTrainerEvents([2],false)
   otherEvent=[]
   for i in triggeredEvents
     if i.id!=thisEvent.id && !$game_self_switches[[$game_map.map_id,i.id,"A"]]
       otherEvent.push(i)
     end
   end
   if otherEvent.length==1
     trainer=pbLoadTrainer(trainerid,trainername,trainerparty)
     Events.onTrainerPartyLoad.trigger(nil,trainer)
     if !trainer
       pbMissingTrainer(trainerid,trainername,trainerparty)
       return false
     end
     if trainer[2].length<=6 # 3
       $PokemonTemp.waitingTrainer=[trainer,thisEvent.id,endspeech]
       return false
     end
   end
 end
 trainer=pbLoadTrainer(trainerid,trainername,trainerparty)
 Events.onTrainerPartyLoad.trigger(nil,trainer)
 if !trainer
   pbMissingTrainer(trainerid,trainername,trainerparty)
   return false
 end
 if $PokemonGlobal.partner && ($PokemonTemp.waitingTrainer || doublebattle)
   othertrainer=PokeBattle_Trainer.new(
      $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
   othertrainer.id=$PokemonGlobal.partner[2]
   othertrainer.party=$PokemonGlobal.partner[3]
   playerparty=[]
   for i in 0...$Trainer.party.length
     playerparty[i]=$Trainer.party[i]
   end
   for i in 0...othertrainer.party.length
     playerparty[6+i]=othertrainer.party[i]
   end
   fullparty1=true
   playertrainer=[$Trainer,othertrainer]
   doublebattle=true
 else
   playerparty=$Trainer.party
   playertrainer=$Trainer
   fullparty1=false
 end
 if $PokemonTemp.waitingTrainer
   combinedParty=[]
   fullparty2=false
   if false
     if $PokemonTemp.waitingTrainer[0][2].length>3
       raise _INTL("Opponent 1's party has more than three PokÃ©mon, which is not allowed")
     end
     if trainer[2].length>3
       raise _INTL("Opponent 2's party has more than three PokÃ©mon, which is not allowed")
     end
   elsif $PokemonTemp.waitingTrainer[0][2].length>3 || trainer[2].length>3
     for i in 0...$PokemonTemp.waitingTrainer[0][2].length
       combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
     end
     for i in 0...trainer[2].length
       combinedParty[6+i]=trainer[2][i]
     end
     fullparty2=true
   else
     for i in 0...$PokemonTemp.waitingTrainer[0][2].length
       combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
     end
     for i in 0...trainer[2].length
       combinedParty[3+i]=trainer[2][i]
     end
     fullparty2=false
   end
   #Sky battle eligibility for opponent
   if skybattle
     count=0
     for poke in combinedParty
       count+=1 if pbCanSkyBattle?(poke)
     end
     if count==0
       Kernel.pbMessage(_INTL("The opponents don't have any eligible pokemon for a sky battle"))
       return false
     end
   end
   scene=pbNewBattleScene
   battle=PokeBattle_Battle.new(scene,playerparty,combinedParty,playertrainer,
      [$PokemonTemp.waitingTrainer[0][0],trainer[0]],skybattle,inverse)
   trainerbgm=pbGetTrainerBattleBGM(
      [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
   battle.fullparty1=fullparty1
   battle.fullparty2=fullparty2
   battle.doublebattle=battle.pbDoubleBattleAllowed?()
   battle.endspeech=$PokemonTemp.waitingTrainer[2]
   battle.endspeech2=endspeech
   battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1]]
 else
   #Sky battle eligibility for opponent
   if skybattle
     count=0
     for poke in trainer[2]
       count+=1 if pbCanSkyBattle?(poke)
     end
     if count==0
       Kernel.pbMessage(_INTL("The opponents don't have any eligible pokemon for a sky battle"))
       return false
     end
   end
   scene=pbNewBattleScene
   battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0],skybattle,inverse)
   battle.fullparty1=fullparty1
   battle.doublebattle=doublebattle ? battle.pbDoubleBattleAllowed?() : false
   battle.endspeech=endspeech
   battle.items=trainer[1]
   trainerbgm=pbGetTrainerBattleBGM(trainer[0])
 end
 if Input.press?(Input::CTRL) && $DEBUG
   Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
   Kernel.pbMessage(_INTL("AFTER LOSING..."))
   Kernel.pbMessage(battle.endspeech)
   Kernel.pbMessage(battle.endspeech2) if battle.endspeech2
   if $PokemonTemp.waitingTrainer
     pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
     $PokemonTemp.waitingTrainer=nil
   end
   return true
 end
 Events.onStartBattle.trigger(nil,nil)
 battle.internalbattle=true
 pbPrepareBattle(battle)
 restorebgm=true
 decision=0
 Audio.me_stop
 pbBattleAnimation(trainerbgm,trainer[0].trainertype,trainer[0].name) { 
    pbSceneStandby {
       decision=battle.pbStartBattle(canlose)
    }
    for i in $Trainer.party; (i.makeUnmega rescue nil); (i.makeUnprimal rescue nil); end
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
        i.makeUnmega rescue nil
        i.makeUnprimal rescue nil
      end
    end
    if decision==2 || decision==5
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
#       else
#         $game_system.bgm_unpause
#         $game_system.bgs_unpause
#         Kernel.pbStartOver
      end
    end
    Events.onEndBattle.trigger(nil,decision,canlose)
    if decision==1
      if $PokemonTemp.waitingTrainer
        pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
      end
    end
 }
 Input.update
 pbSet(variable,decision)
 $PokemonTemp.waitingTrainer=nil
 return (decision==1)
end

def pbDoubleTrainerBattle(trainerid1, trainername1, trainerparty1, endspeech1,
                         trainerid2, trainername2, trainerparty2, endspeech2, 
                         canlose=false,variable=nil,skybattle=false,inverse=false)
 # Sky battle eligibility for player
 if skybattle
   count=0
   for poke in $Trainer.party
     count+=1 if pbCanSkyBattle?(poke)
   end
   if count==0
     Kernel.pbMessage(_INTL("You don't have any eligible pokemon for a sky battle"))
     return false
   end
 end
 trainer1=pbLoadTrainer(trainerid1,trainername1,trainerparty1)
 Events.onTrainerPartyLoad.trigger(nil,trainer1)
 if !trainer1
   pbMissingTrainer(trainerid1,trainername1,trainerparty1)
 end
 trainer2=pbLoadTrainer(trainerid2,trainername2,trainerparty2)
 Events.onTrainerPartyLoad.trigger(nil,trainer2)
 if !trainer2
   pbMissingTrainer(trainerid2,trainername2,trainerparty2)
 end
 if !trainer1 || !trainer2
   return false
 end
 if $PokemonGlobal.partner
   othertrainer=PokeBattle_Trainer.new($PokemonGlobal.partner[1],
                                       $PokemonGlobal.partner[0])
   othertrainer.id=$PokemonGlobal.partner[2]
   othertrainer.party=$PokemonGlobal.partner[3]
   playerparty=[]
   for i in 0...$Trainer.party.length
     playerparty[i]=$Trainer.party[i]
   end
   for i in 0...othertrainer.party.length
     playerparty[6+i]=othertrainer.party[i]
   end
   fullparty1=true
   playertrainer=[$Trainer,othertrainer]
 else
   playerparty=$Trainer.party
   playertrainer=$Trainer
   fullparty1=false
 end
 combinedParty=[]
 for i in 0...trainer1[2].length
   combinedParty[i]=trainer1[2][i]
 end
 for i in 0...trainer2[2].length
   combinedParty[6+i]=trainer2[2][i]
 end
 #Sky battle eligibility for opponent
 if skybattle
   count=0
   for poke in combinedParty
     count+=1 if pbCanSkyBattle?(poke)
   end
   if count==0
     Kernel.pbMessage(_INTL("The opponents don't have any eligible pokemon for a sky battle"))
     return false
   end
 end
 scene=pbNewBattleScene
 battle=PokeBattle_Battle.new(scene,
    playerparty,combinedParty,playertrainer,[trainer1[0],trainer2[0]],skybattle,inverse)
 trainerbgm=pbGetTrainerBattleBGM([trainer1[0],trainer2[0]])
 battle.fullparty1=fullparty1
 battle.fullparty2=true
 battle.doublebattle=battle.pbDoubleBattleAllowed?()
 battle.endspeech=endspeech1
 battle.endspeech2=endspeech2
 battle.items=[trainer1[1],trainer2[1]]
 if Input.press?(Input::CTRL) && $DEBUG
   Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
   Kernel.pbMessage(_INTL("AFTER LOSING..."))
   Kernel.pbMessage(battle.endspeech)
   Kernel.pbMessage(battle.endspeech2) if battle.endspeech2 && battle.endspeech2!=""
   return true
 end
 Events.onStartBattle.trigger(nil,nil)
 battle.internalbattle=true
 pbPrepareBattle(battle)
 restorebgm=true
 decision=0
 pbBattleAnimation(trainerbgm) { 
    pbSceneStandby {
       decision=battle.pbStartBattle(canlose)
    }
    for i in $Trainer.party; (i.makeUnmega rescue nil); (i.makeUnprimal rescue nil); end
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
        i.makeUnmega rescue nil
        i.makeUnprimal rescue nil
      end
    end
    if decision==2 || decision==5
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
#       else
#         $game_system.bgm_unpause
#         $game_system.bgs_unpause
#         Kernel.pbStartOver
      end
    end
    Events.onEndBattle.trigger(nil,decision,canlose)
 }
 Input.update
 pbSet(variable,decision)
 return (decision==1)
end




class PokeBattle_Battle
 attr_accessor :skybattle
 attr_accessor :inverse
 
 alias clauses_initialize initialize
 def initialize(scene,p1,p2,player,opponent,skybattle=false,inverse=false)
   @skybattle=skybattle
   @inverse=inverse
   if @inverse
     PBTypes.setInverse(true)
   end
   clauses_initialize(scene,p1,p2,player,opponent)
 end
 
 def pbCanSkyBattle?(pokemon)
   # list of pokemon that aren't allowed to participate, even though they are flying or have levitate
   inelligible=[getID(PBSpecies,:PIDGEY),getID(PBSpecies,:SPEAROW),getID(PBSpecies,:FARFETCHD),
                getID(PBSpecies,:DODUO),getID(PBSpecies,:DODRIO),getID(PBSpecies,:GENGAR),
                getID(PBSpecies,:HOOTHOOT),getID(PBSpecies,:NATU),getID(PBSpecies,:MURKROW),
                getID(PBSpecies,:DELIBIRD),getID(PBSpecies,:TAILOW),getID(PBSpecies,:STARLY),
                getID(PBSpecies,:CHATOT),getID(PBSpecies,:SHAYMIN),getID(PBSpecies,:PIDOVE),
                getID(PBSpecies,:ARCHEN),getID(PBSpecies,:DUCKLETT),getID(PBSpecies,:RUFFLET),
                getID(PBSpecies,:VULLABY),getID(PBSpecies,:FLETCHLING),getID(PBSpecies,:HAWLUCHA)]
   return (pokemon.hasType?(:FLYING) || pokemon.ability==getID(PBAbilities,:LEVITATE)) &&
             !(inelligible.include?(pokemon.species))
 end
           
 alias clauses_pbCanChooseMove? pbCanChooseMove?
 def pbCanChooseMove?(idxPokemon,idxMove,showMessages,sleeptalk=false)
   ret=clauses_pbCanChooseMove?(idxPokemon,idxMove,showMessages,sleeptalk)
   thispkmn=@battlers[idxPokemon]
   thismove=thispkmn.moves[idxMove]
   if ret && @skybattle && thismove.unusableInSkyBattle?
     if showMessages
       pbDisplayPaused(_INTL("{1} can't be used in a sky battle!",
       thismove.name))
     end
     return false
   end
   return ret
 end
 
 def pbPokemonCount(party)
   count=0
   for i in party
     next if !i
     if !@skybattle
       count+=1 if i.hp>0 && !i.isEgg?
     else
       count+=1 if i.hp>0 && !i.isEgg? && pbCanSkyBattle?(i)
     end
   end
   return count
 end
 
 def pbFindNextUnfainted(party,start,finish=-1)
   finish=party.length if finish<0
   for i in start...finish
     next if !party[i]
     next if @skybattle && !pbCanSkyBattle?(party[i])
     return i if party[i].hp>0 && !party[i].isEgg?
   end
   return -1
 end
 
 alias clauses_pbCanSwitchLax? pbCanSwitchLax?
 def pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
   ret=clauses_pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
   party=pbParty(idxPokemon)
   if ret && @skybattle && !pbCanSkyBattle?(party[pkmnidxTo])
     pbDisplayPaused(_INTL("{1} can't fight in a sky battle!",party[pkmnidxTo].name)) if showMessages
     return false
   end
   return ret
 end
 
end

class PokeBattle_Move
 
 def unusableInSkyBattle?
   inelligible= [ getID(PBMoves,:BODYSLAM), getID(PBMoves,:BULLDOZE), getID(PBMoves,:DIG),
                  getID(PBMoves,:DIVE), getID(PBMoves,:EARTHPOWER), getID(PBMoves,:EARTHQUAKE),
                  getID(PBMoves,:ELECTRICTERRAIN), getID(PBMoves,:FISSURE), getID(PBMoves,:FIREPLEDGE),
                  getID(PBMoves,:FLYINGPRESS), getID(PBMoves,:FRENZYPLANT), getID(PBMoves,:GEOMANCY),
                  getID(PBMoves,:GRASSKNOT), getID(PBMoves,:GRASSPLEDGE), getID(PBMoves,:GRASSYTERRAIN),
                  getID(PBMoves,:GRAVITY), getID(PBMoves,:HEATCRASH), getID(PBMoves,:HEAVYSLAM),
                  getID(PBMoves,:INGRAIN), getID(PBMoves,:LANDSWRATH), getID(PBMoves,:MAGNITUDE),
                  getID(PBMoves,:MATBLOCK), getID(PBMoves,:MISTYTERRAIN), getID(PBMoves,:MUDSPORT),
                  getID(PBMoves,:MUDDYWATER), getID(PBMoves,:ROTOTILLER), getID(PBMoves,:SEISMICTOSS),
                  getID(PBMoves,:SLAM), getID(PBMoves,:SMACKDOWN), getID(PBMoves,:SPIKES),
                  getID(PBMoves,:STOMP), getID(PBMoves,:SUBSTITUTE), getID(PBMoves,:SURF),
                  getID(PBMoves,:TOXICSPIKES), getID(PBMoves,:WATERPLEDGE), getID(PBMoves,:WATERSPORT)
                ]
                
   return inelligible.include?(self.id)
 end
end

#used to determine elligibility before battle
def pbCanSkyBattle?(pokemon)
   # list of pokemon that aren't allowed to participate, even though they are flying or have levitate
   inelligible=[getID(PBSpecies,:PIDGEY),getID(PBSpecies,:SPEAROW),getID(PBSpecies,:FARFETCHD),
                getID(PBSpecies,:DODUO),getID(PBSpecies,:DODRIO),getID(PBSpecies,:GENGAR),
                getID(PBSpecies,:HOOTHOOT),getID(PBSpecies,:NATU),getID(PBSpecies,:MURKROW),
                getID(PBSpecies,:DELIBIRD),getID(PBSpecies,:TAILOW),getID(PBSpecies,:STARLY),
                getID(PBSpecies,:CHATOT),getID(PBSpecies,:SHAYMIN),getID(PBSpecies,:PIDOVE),
                getID(PBSpecies,:ARCHEN),getID(PBSpecies,:DUCKLETT),getID(PBSpecies,:RUFFLET),
                getID(PBSpecies,:VULLABY),getID(PBSpecies,:FLETCHLING),getID(PBSpecies,:HAWLUCHA)]
   return (pokemon.hasType?(:FLYING) || pokemon.ability==getID(PBAbilities,:LEVITATE)) &&
             !(inelligible.include?(pokemon.species))
end

Events.onEndBattle+=proc {|sender,e|
 PBTypes.setInverse(false)
}

class PBTypes
 @@inverse=false
 
 def PBTypes.setInverse(bool)
   @@inverse=bool
 end
 
 def PBTypes.getEffectiveness(attackType,opponentType)
   ret=PBTypes.loadTypeData()[2][attackType*(PBTypes.maxValue+1)+opponentType]
   if @@inverse
     if ret==0 || ret==1
       ret=4
     elsif ret==4
       ret=1
     end
   end
   return ret
 end

end