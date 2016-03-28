def pbForceEvo(pokemon)
  for form in pbGetEvolvedFormData(pokemon.species)
    newspecies=form[2]
  end
  return if !newspecies
  if newspecies>0
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
end

def pbForceDeEvo(pokemon)
  newspecies=pbGetPreviousForm(pokemon.species)
  return if !newspecies
  return if newspecies==pokemon.species
  if newspecies>0
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
end

def pbForceBabyEvo(pokemon)
  newspecies=pbGetBabySpecies(pokemon.species)
  return if !newspecies
  return if newspecies==pokemon.species
  if newspecies>0
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
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

def pbSetNextTransition(transition)
  return if !(transition.is_a?(String))
  $PokemonGlobal.nextTransition=transition
end

#############################################################################
#LevelMod
#############################################################################
def pbLevelModifier(type,factor=nil)
  @levels=[]
  i=0
  ($Trainer.party.length).times do
    @levels.push($Trainer.party[i].level)
    i+=1
  end
  
  @maxlevel=@levels.max
  @sum=$Trainer.party[0].level
  
  i=1
  ($Trainer.party.length-1).times do
    @sum+=$Trainer.party[i].level
    i+=1
  end
  
  @averagelevel=@sum/($Trainer.party.length)
  
    if type=="max"
      level=@maxlevel*factor
    elsif type=="avg"
      level=@averagelevel
    end
  return level
end

#By Luka S.J.
def drawParallelogram(bitmap,rect,color,angle=90)
  angle=angle*(Math::PI/180)
  for i in 0...rect.height
    y=rect.height-i
    x=i/Math.tan(angle)
    bitmap.fill_rect(x+rect.x,y+rect.y,rect.width,1,color)
  end
end
