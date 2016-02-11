class ChallengeSelection
  
  alias random_abil_pbEndScene pbEndScene
  def pbEndScene
    if $PokemonGlobal.randomAbilities
      random_abil_pbEndScene
    else
      random_abil_pbEndScene
      #Create randomized ability hash
      createAbilityHash
    end
  end
  
end

class PokemonGlobalMetadata
  attr_accessor :abilityHash
  
  
  alias random_abil_init initialize
  def initialize
    random_abil_init
    @abilityHash=nil
  end
end

def createAbilityHash
  abilityHash={}
  abilityArr=[]
  for i in 1..PBAbilities.maxValue
    abilityArr.push(i)
  end
  abilityArr.shuffle!
  abilityArr.insert(0,nil)
  for i in 1...abilityArr.length
    abilityHash[i]=abilityArr[i]
  end
  $PokemonGlobal.abilityHash=abilityHash
end

#Overwrite initialize method for pokemon
class PokeBattle_Pokemon
  
  
  alias random_getAbilityList getAbilityList
  def getAbilityList
    ret=random_getAbilityList
    if $PokemonGlobal.randomAbilities
      for i in 0...ret.length
        ret[i][0]=$PokemonGlobal.abilityHash[ret[i][0]]
      end
    end
    return ret
  end
  
  
end