def pbTradeFromPC(tradepoke,tradelevel,trainerName,trainerGender,nickname=nil,ableProc=nil)
  opponent=PokeBattle_Trainer.new(trainerName,trainerGender)
  opponent.setForeignID($Trainer)
  yourPokemon=nil
  if tradepoke.is_a?(PokeBattle_Pokemon)
    tradepoke.trainerID=opponent.id
    tradepoke.ot=opponent.name
    tradepoke.otgender=opponent.gender
    tradepoke.language=opponent.language
    yourPokemon=tradepoke
  else
    if tradepoke.is_a?(String) || tradepoke.is_a?(Symbol)
      raise _INTL("Species does not exist ({1}).",tradepoke) if !hasConst?(PBSpecies,tradepoke)
      tradepoke=getID(PBSpecies,tradepoke)
    end
    yourPokemon=PokeBattle_Pokemon.new(tradepoke,tradelevel,opponent)
  end
  yourPokemon.name=nickname if nickname!=nil
  yourPokemon.resetMoves
  yourPokemon.obtainMode=2 # traded
  scene=PokemonStorageScene.new
  screen=PokemonStorageScreen.new(scene,$PokemonStorage)
  poke=screen.pbChooseTradePoke(yourPokemon,ableProc)
  if poke==nil
    return false
  end
  #Trading Scene
  myPokemon=$PokemonStorage[poke[0]][poke[1]]
  $Trainer.seen[yourPokemon.species]=true
  $Trainer.owned[yourPokemon.species]=true
  pbSeenForm(yourPokemon)
  yourPokemon.pbRecordFirstMoves
  pbFadeOutInWithMusic(99999){
    evo=PokemonTradeScene.new
    evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,opponent.name)
    evo.pbTrade
    evo.pbEndScreen
  }
  $PokemonStorage[poke[0]][poke[1]]=yourPokemon
  return true
end

class PokemonStorageScreen
  
################################################################################
##Choose Pokemon for trading
################################################################################
  def pbChooseTradePoke(tradepoke,ableProc)
   @heldpkmn=nil
    @scene.pbStartBox(self,0)
    retval=nil
    loop do
      selected=@scene.pbSelectBox(@storage.party)
      if selected && selected[0]==-3 # Close box
        if pbConfirm(_INTL("Exit from the Box?"))
          break
        else
          next
        end
      end
      if selected==nil
        if pbConfirm(_INTL("Continue Box operations?"))
          next
        else
          break
        end
      elsif selected[0]==-4 # Box name
        pbBoxCommands
      else
        pokemon=@storage[selected[0],selected[1]]
        next if !pokemon
        commands=[
           _INTL("Select"),
           _INTL("Summary"),
           _INTL("Cancel")
        ]
        helptext=_INTL("Trade this Pokémon for {1}?",PBSpecies.getName(tradepoke.species))
        command=pbShowCommands(helptext,commands)
        case command
          when 0 # Move/Shift/Place
            if pokemon
              if ableProc==nil || ableProc.call(pokemon)
                retval=selected
                break
              else
                pbDisplay(_INTL("This Pokémon can't be chosen."))
              end
            end
          when 1 # Summary
            pbSummary(selected,nil)
          when 2
            retval=nil
            break
        end
      end
    end
    @scene.pbCloseBox
    return retval
  end
end