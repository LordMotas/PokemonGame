class ChallengeSelection
  
  alias random_item_pbEndScene pbEndScene
  def pbEndScene
    if $PokemonGlobal.randomItems
      random_item_pbEndScene
    else
      random_item_pbEndScene
      #Create randomized item hash
      createItemHash
    end
  end
  
end

class PokemonGlobalMetadata
  attr_accessor :itemHash
  
  
  alias random_item_init initialize
  def initialize
    random_item_init
    @itemHash=nil
  end
end

def createItemHash
  itemHash={}
  itemArr=[]
  for i in 1..PBItems.maxValue
    itemArr.push(i)
  end
  itemArr.shuffle!
  itemArr.insert(0,nil)
  for i in 1...itemArr.length
    itemHash[i]=itemArr[i]
  end
  $PokemonGlobal.itemHash=itemHash
end

module Kernel
  
  class << self
    alias random_pbItemBall pbItemBall
    alias random_pbReceiveItem pbReceiveItem
  end
  
  def self.pbItemBall(item,quantity=1)
    if $PokemonGlobal.randomItems
      if !pbIsKeyItem?(item) && !pbIsMachine?(item)
        item=$PokemonGlobal.itemHash[item]
        while (pbIsKeyItem?(item) || pbIsMachine?(item))
          item=0 if item+1>=($PokemonGlobal.itemHash.length)
          item=$PokemonGlobal.itemHash[item+1]
        end
      end
    end
    return self.random_pbItemBall(item,quantity)
  end
  
  def self.pbReceiveItem(item,quantity=1)
    if $PokemonGlobal.randomItems
      if !pbIsKeyItem?(item) && !pbIsMachine?(item)
        item=$PokemonGlobal.itemHash[item]
        while (pbIsKeyItem?(item) || pbIsMachine?(item))
          item=0 if item+1>=($PokemonGlobal.itemHash.length)
          item=$PokemonGlobal.itemHash[item+1]
        end
      end
    end
    return self.random_pbReceiveItem(item,quantity)
  end
  
end

#Randomize items in mart
alias random_pbPokemonMart pbPokemonMart
def pbPokemonMart(stock,speech=nil,cantsell=false)
  if $PokemonGlobal.randomItems
    for i in 0...stock.length
      item=getID(PBItems, stock[i])
      if !pbIsKeyItem?(item) && !pbIsMachine?(item)
        item=$PokemonGlobal.itemHash[item]
        while (pbIsKeyItem?(item) || pbIsMachine?(item))
          item=0 if item+1>=($PokemonGlobal.itemHash.length)
          item=$PokemonGlobal.itemHash[item+1]
        end
        stock[i]=item
      end
    end
  end
  return random_pbPokemonMart(stock,speech,cantsell)
end