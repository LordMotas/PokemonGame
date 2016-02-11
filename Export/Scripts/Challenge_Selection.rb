class ChallengeSelection
  
  alias random_pbEndScene pbEndScene
  def pbEndScene
    if $PokemonGlobal.encounterPureRandom || 
       $PokemonGlobal.encounterSetRandom ||
       $PokemonGlobal.encounterPsuedoRandom
         random_pbEndScene
    else
        random_pbEndScene
        #Create randomized Pokemon hashes
        createPsuedoRandomPokemonHash
    end
  end
  
end

class PokemonGlobalMetadata
  attr_accessor :psuedoHash
  attr_accessor :psuedoBSTHash
  
  
  alias random_init initialize
  def initialize
    random_init
    @psuedoHash=nil
    @psuedoBSTHash=nil
  end
end

def createPsuedoRandomPokemonHash
  # create hash
  psuedoHash = Hash.new
  psuedoBSTHash = Hash.new
  
  #Create array of all pokemon dex numbers
  pokeArray = []
  for i in 1..PBSpecies.maxValue
    pokeArray.push(i)
  end
  #randomize hash
  pokeArrayRand = pokeArray.dup
  pokeArrayRand.shuffle!
  pokeArray.insert(0,nil)
  # fill random hash
  #random hash will have to be accessed by number, not internal name
  for i in 1...pokeArrayRand.length
    psuedoHash[i]=pokeArrayRand[i]
  end
  
  #use pokeArrayRand to fill in the BST hash also
  #loop through the actual dex, and use the first mon in pokeArrayRand with
  #BST in the same 100 range
  for i in 1..PBSpecies.maxValue
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,i,10)
    baseStats=[
       dexdata.fgetb, # HP
       dexdata.fgetb, # Attack
       dexdata.fgetb, # Defense
       dexdata.fgetb, # Speed
       dexdata.fgetb, # Special Attack
       dexdata.fgetb  # Special Defense
    ]
    baseStat_target = 0
    for k in 0...baseStats.length
      baseStat_target+=baseStats[k]
    end
    baseStat_target = (baseStat_target/50).floor
    dexdata.close
    for j in 1...pokeArrayRand.length
      dexdata=pbOpenDexData
      pbDexDataOffset(dexdata,pokeArrayRand[j],10)
      baseStats=[
         dexdata.fgetb, # HP
         dexdata.fgetb, # Attack
         dexdata.fgetb, # Defense
         dexdata.fgetb, # Speed
         dexdata.fgetb, # Special Attack
         dexdata.fgetb  # Special Defense
      ]
      dexdata.close
      baseStat_temp = 0
      for l in 0...baseStats.length
        baseStat_temp+=baseStats[l]
      end
      baseStat_temp = (baseStat_temp/50).floor
      #if a match, add to hash, remove from array, and cycle to next poke in dex
      if baseStat_temp == baseStat_target
        psuedoBSTHash[i]=pokeArrayRand[j]
        pokeArrayRand.delete(pokeArrayRand[j])
        break
      end
    end
  end
  
  #add hashes to global data
  $PokemonGlobal.psuedoHash = psuedoHash
  $PokemonGlobal.psuedoBSTHash = psuedoBSTHash  
end

#Overwrite initialize method for pokemon
class PokeBattle_Pokemon
  
  alias random_init initialize
  #the encounter type "Normal" encompasses trainer and wild encounters.  
  #gift and event encounters are handled by seperate values in $PokemonGlobal
  def initialize(species,level,player=nil,withMoves=true,encType="Normal")
    #change species to number if needed
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    cname=getConstantName(PBSpecies,species) rescue nil
    if !species || species<1 || species>PBSpecies.maxValue || !cname
      raise ArgumentError.new(_INTL("The species number (no. {1} of {2}) is invalid.",
         species,PBSpecies.maxValue))
      return nil
    end
    #check appropriate $PokemonGlobal factors, and then change the species
    case encType
    when "Normal"
      if $PokemonGlobal.encounterPureRandom
        species=rand(PBSpecies.maxValue)+1
      elsif $PokemonGlobal.encounterSetRandom
        #set to new species number
        species=$PokemonGlobal.psuedoHash[species]
      elsif $PokemonGlobal.encounterPsuedoRandom
        #set to new species number
        species=$PokemonGlobal.psuedoBSTHash[species]
      end
    when "Gift"
      if $PokemonGlobal.giftPureRandom
        species=rand(PBSpecies.maxValue)+1
      elsif $PokemonGlobal.giftSetRandom
        #set to new species number
        species=$PokemonGlobal.psuedoHash[species]
      elsif $PokemonGlobal.giftPsuedoRandom
        #set to new species number
        species=$PokemonGlobal.psuedoBSTHash[species]
      end
    when "Event"
      if $PokemonGlobal.eventPureRandom
        species=rand(PBSpecies.maxValue)+1
      elsif $PokemonGlobal.eventSetRandom
        #set to new species number
        species=$PokemonGlobal.psuedoHash[species]
      elsif $PokemonGlobal.eventPsuedoRandom
        #set to new species number
        species=$PokemonGlobal.psuedoBSTHash[species]
      end
    end   
    #now initialize the new pokemon
    random_init(species,level,player,withMoves)
  end
  
end