################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_switches[SHINY_WILD_POKEMON_SWITCH]
     pokemon.makeShiny
   end
}

# Used in the random dungeon map.  Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_map.map_id==51
     pokemon.level=pbBalancedLevel($Trainer.party) - 4 + rand(5)   # For variety
     pokemon.calcStats
     pokemon.resetMoves
   end
}

# This is the basis of a trainer modifier.  It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
# Note that you can only modify a partner trainer's Pokémon, and not the trainer
# themselves nor their items this way, as those are generated from scratch
# before each battle.
#Events.onTrainerPartyLoad+=proc {|sender,e|
#   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
#     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
#     items=e[0][1]   # An array of the trainer's items they can use
#     party=e[0][2]   # An array of the trainer's Pokémon
#     YOUR CODE HERE
#   end
#}

Events.onTrainerPartyLoad+=proc {|sender,e|
  if $game_switches[59]
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
     for poke in party
        poke.species=1+rand(PBSpecies.maxValue)
        poke.level=(pbLevelModifier("max",1)*9/10.floor)+rand(4)-rand(8)
        poke.calcStats
        poke.resetMoves
        poke.species = pbGetBabySpecies(poke.species) # revert to the first evolution
          item = 0
          loop do
            nl = poke.level + 5
            nl = MAXIMUMLEVEL if nl > MAXIMUMLEVEL
            pkmn = PokeBattle_Pokemon.new(poke.species, nl)
            cevo = Kernel.pbCheckEvolution(pkmn)
            evo = pbGetEvolvedFormData(poke.species)
            if evo
              evo = evo[rand(evo.length - 1)]
              # evolve the species if we can't evolve and there is an evolution
              # and a bit of randomness passes as well as the evolution type cannot
              # be by level
              if evo && cevo < 1 && rand(MAXIMUMLEVEL) <= poke.level
                species = evo[2] if evo[0] != 4 && rand(MAXIMUMLEVEL) <= poke.level
              end
            end
            if cevo == -1 || (rand(MAXIMUMLEVEL) > poke.level && poke.level < 60)
              # ^ Only break the loop if there is no more evolutions or some randomness
              # applies and the level is under 60 
              break
            else
              poke.species = evo[2]
            end
          end
           poke.name=PBSpecies.getName(poke.species)
           poke.calcStats
           poke.resetMoves     
         end
         #sometimes give HA
         abil=poke.getAbilityList
         if abil.length>2 && rand(100)<25
           poke.setAbility(2)
        end
      end
    end
}