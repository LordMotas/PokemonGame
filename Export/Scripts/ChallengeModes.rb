#===============================================================================
# * Nuzlocke Mode - by JV (additional options by mej71)
#===============================================================================
#
# This script is for Pokémon Essentials. It adds support for the famous fan
# created Nuzlocke Mode, where Pokémon are considered dead when fainted and
# the player is only able to capture the first pokémon they spot in each map.
#
#
# Features included:
#  - Only one encounter per Map
#  - Optional Dubious Clause (same species encounter doesn't count)
#  - Support for connected maps (so you don't get 2 encounters in the same route)
#  - Permadeath (no healing or revive)
#

# Connected Maps (so you don't get 2 encounters in the same route)
# example: (It's an array of arrays, simple as that, just mimic the example)
=begin
NUZLOCKEMAPS = [
[5,21],
[2,7,12]
]
=end

#===============================================================================

################################################################################
#               Add variables and accessors to be saved/referenced
################################################################################
class PokemonGlobalMetadata
  
  #nuzlocke stuff
  attr_accessor :nuzlocke
  attr_accessor :dubiousClause
  attr_accessor :shinyClause
  attr_accessor :catchTokens
  attr_accessor :encounterTokens
  attr_accessor :ppTokens
  attr_accessor :reviveTokens
  attr_accessor :catchTokenAfterGymLeader
  attr_accessor :catchTokenAfterGiftPokemon
  attr_accessor :encounterTokenAfterGymLeader
  attr_accessor :encounterTokenAfterGiftPokemon
  attr_accessor :reviveTokenAfterGymLeader
  attr_accessor :reviveTokenAfterGiftPokemon
  attr_accessor :ppClause
  attr_accessor :allowPPItems

  #randomize stuff
  attr_accessor :encounterPureRandom
  attr_accessor :encounterSetRandom
  attr_accessor :encounterPsuedoRandom
  attr_accessor :giftPureRandom
  attr_accessor :giftSetRandom
  attr_accessor :giftPsuedoRandom
  attr_accessor :eventPureRandom
  attr_accessor :eventSetRandom
  attr_accessor :eventPsuedoRandom
  attr_accessor :randomMoves
  attr_accessor :randomAbilities
  attr_accessor :randomItems
  
  attr_accessor :noRunningLocke
  attr_accessor :noEvoLocke
  attr_accessor :soloLocke
  attr_accessor :inverseLocke
  attr_accessor :noItemsLocke
  attr_accessor :noTMLocke
  
  
  
  attr_accessor :nuzlockeMaps
  
  alias nuzlocke_initialize initialize
  def initialize
    @nuzlocke                       = false
    @dubiousClause                  = false
    @ppClause                       = false
    @allowPPItems                   = true
    @catchTokens                    = -1
    @ppTokens                       = -1
    @reviveTokens                   = -1
    @encounterTokens                = -1
    @useNuzlockeTokens              = false
    @catchTokenAfterGymLeader       = false
    @catchTokenAfterGiftPokemon     = false
    @encounterTokenAfterGymLeader   = false
    @encounterTokenAfterGiftPokemon = false
    @reviveTokenAfterGymLeader      = false
    @reviveTokenAfterGiftPokemon    = false
    @noRunningLocke                 = false
    @noEvoLocke                     = false
    @soloLocke                      = false
    @inverseLocke                   = false
    @noItemsLocke                   = false
    @noTMLocke                      = false
    @shinyClause                    = false
    @encounterPureRandom            = false
    @encounterSetRandom             = false
    @encounterPsuedoRandom          = false
    @giftPureRandom                 = false
    @giftSetRandom                  = false
    @giftPsuedoRandom               = false
    @eventPureRandom                = false
    @eventSetRandom                 = false
    @eventPsuedoRandom              = false
    @randomMoves                    = false
    @randomAbilities                = false
    @randomItems                    = false
    @nuzlockeMaps                   = []
    nuzlocke_initialize
  end
  
  def nuzlockeMapState(mapid)
    if !@nuzlockeMaps
      @nuzlockeMaps=[]
    end
    return 0 if @nuzlockeMaps.length==0
    for i in 0...@nuzlockeMaps.length
      if @nuzlockeMaps[i][0] == mapid
        state = @nuzlockeMaps[i][1]
        echo("(")
        echo(@nuzlockeMaps)
        echo("->")
        echo(state)
        echo(")\n")
        return state
        break
      end
    end
  end
  
  def checkDuplicates(mapid)
    return false if !@nuzlockeMaps
    for i in 0...@nuzlockeMaps.length
      if @nuzlockeMaps[i][0] == mapid
        return true
      end
    end
    return false
  end
end

################################################################################
#                             Token Controllers
################################################################################
def pbAddCatchTokens(amount)
  return if !$PokemonGlobal.nuzlocke
  return if $PokemonGlobal.catchTokens<0
  $PokemonGlobal.catchTokens+=amount
end

def pbReduceCatchTokens(amount)
  return if !$PokemonGlobal.nuzlocke
  return if $PokemonGlobal.catchTokens<0
  $PokemonGlobal.catchTokens-=amount
end

def pbAddPPTokens(amount)
  return if !$PokemonGlobal.nuzlocke
  return if $PokemonGlobal.ppTokens<0
  $PokemonGlobal.ppTokens+=amount
end

def pbReducePPTokens(amount)
  return if !$PokemonGlobal.nuzlocke
  return if $PokemonGlobal.ppTokens<0
  $PokemonGlobal.ppTokens-=amount
end

def pbAddReviveTokens(amount)
  return if !$PokemonGlobal.nuzlocke
  return if $PokemonGlobal.reviveTokens<0
  $PokemonGlobal.reviveTokens+=amount
end

def pbReduceReviveTokens(amount)
  return if !$PokemonGlobal.nuzlocke
  return if $PokemonGlobal.reviveTokens<0
  $PokemonGlobal.reviveTokens-=amount
end
################################################################################
#Check during catch to prevent catching Pokemon on maps you've already fought a wild battle on
#Also stores the information at the end of the battle
#TODO:  Have a variable to notate a special battle (any event encounter) so the catch rules don't apply
################################################################################
class PokeBattle_Battle
  
  alias nuzlocke_ThrowPokeBall pbThrowPokeBall
  def pbThrowPokeBall(idxPokemon,ball,rareness=nil)
    if $PokemonGlobal.nuzlocke
      if (!(self.battlers[idxPokemon].isShiny?) && $PokemonGlobal.shinyClause)
        nuzlockeMultipleMaps
        if $PokemonGlobal.nuzlockeMapState($game_map.map_id) == 1 && !@usingToken
          if $PokemonGlobal.catchTokens>0
            if pbShowCommands(_INTL("You've already fought a pokemon in this area, would you like to use a token to try and catch this one?"),[_INTL("Yes"),_INTL("No")],1)==0
              @usingToken=true
              pbReduceCatchTokens(1)
            end
          end
          if !@usingToken
            pbDisplay(_INTL("But {1} already fought a wild pokemon on this area!",self.pbPlayer.name))
            return
          end
        end
        if $PokemonGlobal.nuzlockeMapState($game_map.map_id) == 2 && !@usingToken
          if $PokemonGlobal.catchTokens>0
            if pbShowCommands(_INTL("You've already caught a pokemon in this area, would you like to use a token to try and catch this one?"),[_INTL("Yes"),_INTL("No")],1)==0
              @usingToken=true
              pbReduceCatchTokens(1)
            end
          end
          if !@usingToken
            pbDisplay(_INTL("But {1} already caught a wild pokemon on this area!",self.pbPlayer.name))
            return
          end
        end
      end
    end
    nuzlocke_ThrowPokeBall(idxPokemon,ball,rareness=nil)
  end
  
  alias nuzlocke_EndOfBattle pbEndOfBattle
  def pbEndOfBattle(canlose=false)
    nuzlocke_EndOfBattle
    if $PokemonGlobal.nuzlocke
      if @decision == 4
        $PokemonGlobal.nuzlockeMaps.push([$game_map.map_id,2])
      end
      if !@opponent && $PokemonGlobal.nuzlockeMapState($game_map.map_id) != 2
        $PokemonGlobal.nuzlockeMaps.push([$game_map.map_id,1]) if !$PokemonGlobal.dubiousClause 
        $PokemonGlobal.nuzlockeMaps.push([$game_map.map_id,1]) if ($PokemonGlobal.dubiousClause  && !@battlers[1].owned)
      end
    end
  end
  
  def nuzlockeMultipleMaps
    return if !NUZLOCKEMAPS
    for i in 0...NUZLOCKEMAPS.length
      for j in 0...NUZLOCKEMAPS[i].length
        mapid = NUZLOCKEMAPS[i][j]
        if $PokemonGlobal.nuzlockeMapState(mapid) && $game_map.map_id != mapid && !$PokemonGlobal.checkDuplicates($game_map.map_id)
          if ($PokemonGlobal.nuzlockeMapState(mapid) != 0 && NUZLOCKEMAPS[i].include?($game_map.map_id))
            $PokemonGlobal.nuzlockeMaps.push([$game_map.map_id,$PokemonGlobal.nuzlockeMapState(mapid)]) 
          end
        end
      end
    end
  end
end

################################################################################
# Stop healing dead pokemon during nuzlocke
# Stop healing PP during a PP Locke (unless you sacrifice a PP token)
################################################################################
class PokeBattle_Pokemon  
  
  alias nuzlocke_heal heal
  def heal
    return if self.isEgg?
    if hp<=0 && $PokemonGlobal.nuzlocke
      if $PokemonGlobal.reviveTokens>0
        if Kernel.pbShowCommands(_INTL("You have a token available, would you like to revive {1}",@name),[_INTL("Yes"),_INTL("No")],1)==0
          pbReduceReviveTokens(1)
        else
          return
        end
      end
    end
    healHP
    healStatus
    healPP
  end
  
  alias nuzlocke_healPP healPP
  def healPP(index=-1)
    if $PokemonGlobal.ppClause
      if $PokemonGlobal.ppTokens>0
        if Kernel.pbShowCommands(_INTL("You have a token available, would you like to heal the PP of your pokemon?"),[_INTL("Yes"),_INTL("No")],1)==0
          pbReducePPTokens(1)
          nuzlocke_healPP(index)
        end
      end
    else
      nuzlocke_healPP(index)
    end
  end
  
end  

def pbHealAll
  return if !$Trainer
  for i in $Trainer.party
    if $PokemonGlobal.nuzlocke && $PokemonGlobal.reviveTokens<=0
      if i.hp > 0
        i.heal
      end
    else
      i.heal
    end
  end
end

################################################################################
#  Prevent PP healing items if allowPPItems clause is false
################################################################################
alias nuzlocke_pbRestorePP pbRestorePP
def pbRestorePP(pokemon,move,pp)
  if !$PokemonGlobal.allowPPItems
    Kernel.pbMessage(_INTL("You are not allowed to use PP Items during your playthrough"))
    return 0
  end
  return nuzlocke_pbRestorePP(pokemon,move,pp)
end

################################################################################
#  Prevent Evolutions when no evo clause
################################################################################

alias challenge_pbEvolutionCheck pbEvolutionCheck

def pbEvolutionCheck(currentlevels)
  challenge_pbEvolutionCheck(currentlevels) if !$PokemonGlobal.noEvoLocke
end

################################################################################
#  Force inverse battles for inverse clause
################################################################################
class PokeBattle_Battle
  
  alias challenge_init initialize
  
  def initialize(scene,p1,p2,player,opponent,skybattle=false,inverse=false)
    inverse=true if $PokemonGlobal.inverseLocke
    challenge_init(scene,p1,p2,player,opponent,skybattle,inverse)
  end
  
end

################################################################################
#  Rewrite methods to enforce solo run
################################################################################

class PokemonStorageScreen
  
  alias challenge_pbWithdraw pbWithdraw
  def pbWithdraw(selected,heldpoke)
    return challenge_pbWithdraw(selected,heldpoke) if !$PokemonGlobal.soloLocke
    box=selected[0]
    index=selected[1]
    if box==-1
      raise _INTL("Can't withdraw from party...");
    end
    if @storage.party.nitems==1 #soloLocke
      pbDisplay(_INTL("Your party's full!"))
      return false
    end
    @scene.pbWithdraw(selected,heldpoke,@storage.party.length)
    if heldpoke
      @storage.pbMoveCaughtToParty(heldpoke)
      @heldpkmn=nil
    else
      @storage.pbMove(-1,-1,box,index)
    end
    @scene.pbRefresh
    return true
  end
  
  alias challenge_pbSwap pbSwap
  def pbSwap(selected)
    return challenge_pbSwap(selected) if !$PokemonGlobal.soloLocke
    box=selected[0]
    index=selected[1]
    if !@storage[box,index]
      raise _INTL("Position {1},{2} is empty...",box,index)
    end
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1 && !pbAble?(@heldpkmn)
      pbDisplay(_INTL("That's your last Pokémon!"))
      return false
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box==-1 && $Trainer.party.length==1
      pbDisplay(_INTL("Can't change Pokemon during a Solo Run!"))
      return
    end
    @scene.pbSwap(selected,@heldpkmn)
    @heldpkmn.heal if box>=0
    tmp=@storage[box,index]
    @storage[box,index]=@heldpkmn
    @heldpkmn=tmp
    @scene.pbRefresh
    return true
  end
  
  alias challenge_pbPlace pbPlace
  def pbPlace(selected)
    return challenge_pbPlace(selected) if !$PokemonGlobal.soloLocke
    box=selected[0]
    index=selected[1]
    if @storage[box,index]
      raise _INTL("Position {1},{2} is not empty...",box,index)
    end
    if box!=-1 && index>=@storage.maxPokemon(box)
      pbDisplay(_INTL("Can't place that there."))
      return
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay(_INTL("Please remove the mail."))
      return
    end
    if box==-1 && $Trainer.party.length==1
      pbDisplay(_INTL("Can't add Pokemon during a Solo Run!"))
      return
    end
    @heldpkmn.heal if box>=0
    @scene.pbPlace(selected,@heldpkmn)
    @storage[box,index]=@heldpkmn
    if box==-1
      @storage.party.compact!
    end
    @scene.pbRefresh
    @heldpkmn=nil
  end
  
end

alias challenge_pbBoxesFull? pbBoxesFull?
def pbBoxesFull? #soloLock
  return challenge_pbBoxesFull? if !$PokemonGlobal.soloLocke
  return !$Trainer || ($Trainer.party.length==1 && $PokemonStorage.full?)
end

alias challenge_pbStorePokemon pbStorePokemon
def pbStorePokemon(pokemon)
  return challenge_pbStorePokemon(pokemon) if !$PokemonGlobal.soloLocke
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<1
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    oldcurbox=$PokemonStorage.currentBox
    storedbox=$PokemonStorage.pbStoreCaught(pokemon)
    curboxname=$PokemonStorage[oldcurbox].name
    boxname=$PokemonStorage[storedbox].name
    creator=nil
    creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
    if storedbox!=oldcurbox
      if creator
        Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
      else
        Kernel.pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
      end
      Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
    else
      if creator
        Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
      else
        Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
      end
      Kernel.pbMessage(_INTL("It was stored in box \"{1}.\"",boxname))
    end
  end
end

alias challenge_pbAddPokemonSilent pbAddPokemonSilent
def pbAddPokemonSilent(pokemon,level=nil,seeform=true)
  return challenge_pbAddPokemonSilent(pokemon,level,seeform) if !$PokemonGlobal.soloLocke
  return false if !pokemon || pbBoxesFull? || !$Trainer
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<1
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  return true
end

alias challenge_pbAddToPartySilent pbAddToPartySilent
def pbAddToPartySilent(pokemon,level=nil,seeform=true)
  return challenge_pbAddToPartySilent(pokemon,level,seeform) if !$PokemonGlobal.soloLocke
  return false if !pokemon || !$Trainer || $Trainer.party.length==1
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length]=pokemon
  return true
end

################################################################################
#  Enforce no items 
################################################################################

module ItemHandlers
    class << self
      alias challenge_hasOutHandler hasOutHandler
    end
    
    def self.hasOutHandler(item) 
      return self.challenge_hasOutHandler(item) if !$PokemonGlobal.noItemsLocke 
      ret=UseFromBag[item]!=nil || UseOnPokemon[item]!=nil
      if ret
        if $PokemonGlobal.noItemsLocke && !pbIsKeyItem?(item)
          return false
        end
      end
      return ret
    end
    
end
  
################################################################################
#  Enforce nicknames on hatch
################################################################################
class PokemonEggHatchScene
  def pbStartScene(pokemon)
    @sprites={}
    @pokemon=pokemon
    @nicknamed=false
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundOrColoredPlane(@sprites,"background","hatchbg",
       Color.new(248,248,248),@viewport)
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setSpeciesBitmap(@pokemon.species,@pokemon.isFemale?,
                                         (@pokemon.form rescue 0),@pokemon.isShiny?,
                                         false,false,true) # Egg sprite
    @sprites["pokemon"].x=Graphics.width/2-@sprites["pokemon"].bitmap.width/2
    @sprites["pokemon"].y=48+(Graphics.height-@sprites["pokemon"].bitmap.height)/2
    @sprites["hatch"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=200
    @sprites["overlay"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["overlay"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,
        Color.new(255,255,255))
    @sprites["overlay"].opacity=0
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    crackfilename=sprintf("Graphics/Battlers/%seggCracks",getConstantName(PBSpecies,@pokemon.species)) rescue nil
    if !pbResolveBitmap(crackfilename)
      crackfilename=sprintf("Graphics/Battlers/%03deggCracks",@pokemon.species)
      if !pbResolveBitmap(crackfilename)
        crackfilename=sprintf("Graphics/Battlers/eggCracks")
      end
    end
    crackfilename=pbResolveBitmap(crackfilename)
    hatchSheet=AnimatedBitmap.new(crackfilename)
    pbBGMPlay("evolv")
    # Egg animation
    updateScene(60)
    pbPositionHatchMask(hatchSheet,0)
    pbSEPlay("ballshake")
    swingEgg(2)
    updateScene(8)
    pbPositionHatchMask(hatchSheet,1)
    pbSEPlay("ballshake")
    swingEgg(2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet,2)
    pbSEPlay("ballshake")
    swingEgg(4,2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet,3)
    pbSEPlay("ballshake")
    swingEgg(8,4)
    updateScene(8)
    pbPositionHatchMask(hatchSheet,4)
    pbSEPlay("recall")
    # Fade and change the sprite
    fadeSpeed=15
    for i in 1..(255/fadeSpeed)
      @sprites["pokemon"].tone=Tone.new(i*fadeSpeed,i*fadeSpeed,i*fadeSpeed)
      @sprites["overlay"].opacity=i*fadeSpeed
      updateScene
    end
    updateScene(30)
    @sprites["pokemon"].setPokemonBitmap(@pokemon) # Pokémon sprite
    @sprites["pokemon"].x=Graphics.width/2-@sprites["pokemon"].bitmap.width/2
    @sprites["pokemon"].y=-8+(Graphics.height-@sprites["pokemon"].bitmap.height)/2
    metrics=load_data("Data/metrics.dat")
    @sprites["pokemon"].y+=(metrics[1][@pokemon.species] || 0)*2 - (metrics[2][@pokemon.species] || 0)*2
    @sprites["hatch"].visible=false
    for i in 1..(255/fadeSpeed)
      @sprites["pokemon"].tone=Tone.new(255-i*fadeSpeed,255-i*fadeSpeed,255-i*fadeSpeed)
      @sprites["overlay"].opacity=255-i*fadeSpeed
      updateScene
    end
    @sprites["pokemon"].tone=Tone.new(0,0,0)
    @sprites["overlay"].opacity=0
    # Finish scene
    frames=pbCryFrameLength(@pokemon.species)
    pbBGMStop()
    pbPlayCry(@pokemon)
    updateScene(frames)
    Kernel.setMessageSprites(@sprites)
    pbMEPlay("EvolutionSuccess")
    Kernel.pbMessage(_INTL("\\se[]{1} hatched from the Egg!\\wt[80]",@pokemon.name)) { update }
    if $PokemonGlobal.nuzlocke || Kernel.pbConfirmMessage(
        _INTL("Would you like to nickname the newly hatched {1}?",@pokemon.name))
      if $PokemonGlobal.nuzlocke
        # Force the player to choose a nickname
        while (nickname=="" || nickname==@pokemon.name) do
          nickname=@scene.pbNameEntry(_INTL("{1}'s nickname?",species),@pokemon)
        end
        @nicknamed=true
      else
        nickname=@scene.pbNameEntry(_INTL("{1}'s nickname?",species),@pokemon)
        @pokemon.name=nickname if nickname!=""
        @nicknamed=true
      end
    end
  end
  
end

################################################################################
#  Enforce no running
################################################################################
class PokeBattle_Battle
  
  alias rand_run pbRun
  def pbRun(idxPokemon,duringBattle=false)
    if $PokemonGlobal.noRunningLocke
      pbDisplayPaused(_INTL("Can't escape!"))
      return 0
    else
      return rand_run(idxPokemon,duringBattle)
    end
  end
  
end

################################################################################
#  Enforce no items and no tms clauses
################################################################################
class PokemonBagScreen
  
  # UI logic for withdrawing an item in the item screen.
  def pbWithdrawItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage=PCItemStorage.new
    end
    storage=$PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item=@scene.pbChooseItem
      break if item==0
      commands=[_INTL("Withdraw"),_INTL("Give"),_INTL("Cancel")]
      itemname=PBItems.getName(item)
      
      command=@scene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
      if command==0
        qty=storage.pbQuantity(item)
        if qty>1
          qty=@scene.pbChooseNumber(_INTL("How many do you want to withdraw?"),qty)
        end
        if qty>0
          itemname=PBItems.getNamePlural(item) if qty>1
          if !@bag.pbCanStore?(item,qty)
            pbDisplay(_INTL("There's no more room in the Bag."))
          else
            pbDisplay(_INTL("Withdrew {1} {2}.",qty,itemname))
            if !storage.pbDeleteItem(item,qty)
              raise "Can't delete items from storage"
            end
            if !@bag.pbStoreItem(item,qty)
              raise "Can't withdraw items from storage"
            end
          end
        end
      elsif command==1 # Give
        if  $PokemonGlobal.noItemsLocke #mej71 no items
          @scene.pbDisplay(_INTL("Can't give items in a No Items Locke!"))
          return 0
        end
        if $Trainer.pokemonCount==0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
          return 0
        elsif pbIsImportantItem?(item)
          @scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
        else
          pbFadeOutIn(99999){
             sscene=PokemonScreen_Scene.new
             sscreen=PokemonScreen.new(sscene,$Trainer.party)
             if sscreen.pbPokemonGiveScreen(item)
               # If the item was held, delete the item from storage
               if !storage.pbDeleteItem(item,1)
                 raise "Can't delete item from storage"
               end
             end
             @scene.pbRefresh
          }
        end
      end
    end
    @scene.pbEndScene
  end
  
  def pbStartScreen
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      cmdUse=-1
      cmdRegister=-1
      cmdGive=-1
      cmdToss=-1
      cmdRead=-1
      cmdMysteryGift=-1
      commands=[]
      # Generate command list
      commands[cmdRead=commands.length]=_INTL("Read") if pbIsMail?(item)
      commands[cmdUse=commands.length]=_INTL("Use") if ItemHandlers.hasOutHandler(item) || (pbIsMachine?(item) && $Trainer.party.length>0 && !$PokemonGlobal.noTMLocke)
      commands[cmdGive=commands.length]=_INTL("Give") if $Trainer.party.length>0 && !pbIsImportantItem?(item) && !$PokemonG
      commands[cmdToss=commands.length]=_INTL("Toss") if !pbIsImportantItem?(item) || $DEBUG
      if @bag.registeredItem==item
        commands[cmdRegister=commands.length]=_INTL("Deselect")
      elsif pbIsKeyItem?(item) && ItemHandlers.hasKeyItemHandler(item)
        commands[cmdRegister=commands.length]=_INTL("Register")
      end
      commands[cmdMysteryGift=commands.length]=_INTL("Make Mystery Gift") if $DEBUG
      commands[commands.length]=_INTL("Cancel")
      # Show commands generated above
      itemname=PBItems.getName(item) # Get item name
      command=@scene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
      if cmdUse>=0 && command==cmdUse # Use item
        ret=pbUseItem(@bag,item,@scene)
        # 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
        break if ret==2 # End screen
        @scene.pbRefresh
        next
      elsif cmdRead>=0 && command==cmdRead # Read mail
        pbFadeOutIn(99999){
           pbDisplayMail(PokemonMail.new(item,"",""))
        }
      elsif cmdRegister>=0 && command==cmdRegister # Register key item
        @bag.pbRegisterKeyItem(item)
        @scene.pbRefresh
      elsif cmdGive>=0 && command==cmdGive # Give item to Pokémon
        if $Trainer.pokemonCount==0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
        elsif pbIsImportantItem?(item)
          @scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
        else
          # Give item to a Pokémon
          pbFadeOutIn(99999){
             sscene=PokemonScreen_Scene.new
             sscreen=PokemonScreen.new(sscene,$Trainer.party)
             sscreen.pbPokemonGiveScreen(item)
             @scene.pbRefresh
          }
        end
      elsif cmdToss>=0 && command==cmdToss # Toss item
        qty=@bag.pbQuantity(item)
        if qty>1
          helptext=_INTL("Toss out how many {1}?",PBItems.getNamePlural(item))
          qty=@scene.pbChooseNumber(helptext,qty)
        end
        if qty>0
          itemname=PBItems.getNamePlural(item) if qty>1
          if pbConfirm(_INTL("Is it OK to throw away {1} {2}?",qty,itemname))
            pbDisplay(_INTL("Threw away {1} {2}.",qty,itemname))
            qty.times { @bag.pbDeleteItem(item) }      
          end
        end   
      elsif cmdMysteryGift>=0 && command==cmdMysteryGift   # Export to Mystery Gift
        pbCreateMysteryGift(1,item)
      end
    end
    @scene.pbEndScene
    return item
  end

end

def pbSetDSIFont(bitmap)
  bitmap.font.size=31
  bitmap.font.name=MessageConfig.pbTryFonts("Agency FB","Arial Narrow","Arial")
end