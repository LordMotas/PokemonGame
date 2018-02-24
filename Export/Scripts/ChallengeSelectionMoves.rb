class ChallengeSelection
  
  alias random_move_pbEndScene pbEndScene
  def pbEndScene
    if $PokemonGlobal.randomMoves
      random_move_pbEndScene
    else
      random_move_pbEndScene
      #Create randomized move hash
      createMoveHash
    end
  end
  
end

class PokemonGlobalMetadata
  attr_accessor :moveHash
  
  
  alias random_move_init initialize
  def initialize
    random_move_init
    @moveHash=nil
  end
end

def createMoveHash
  moveHash={}
  moveArr=[]
  for i in 1..PBMoves.maxValue
    moveArr.push(i)
  end
  moveArr.shuffle!
  moveArr.insert(0,nil)
  for i in 1...moveArr.length
    moveHash[i]=moveArr[i]
  end
  $PokemonGlobal.moveHash=moveHash
end

class PokeBattle_Pokemon
  
  alias random_getMoveList getMoveList
  def getMoveList
    ret=random_getMoveList
    if $PokemonGlobal.randomMoves
      for i in 0...ret.length
        ret[i][1]=$PokemonGlobal.moveHash[ret[i][1]]
      end
    end
    return ret  
  end
  
end