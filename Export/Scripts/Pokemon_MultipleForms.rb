class PokeBattle_Pokemon
  def form
    v=MultipleForms.call("getForm",self)
    if v!=nil
      self.form=v if !@form || v!=@form
      return v
    end
    return @form || 0
  end

  def form=(value)
    @form_change_time=pbGetTimeNow if @form != value
    @form=value
    self.calcStats
    MultipleForms.call("onSetForm",self,value)
  end

  def formOffsetY
    v=MultipleForms.call("getOffsetY",self)
    if v!=nil
      @formOffsetY=v if !@formOffsetY || v!=@formOffsetY
      return v
    end
    return @formOffsetY || 0
  end
  
  def formNoCall=(value)
    @form=value
    self.calcStats
  end

  def hasMegaForm?
    v=MultipleForms.call("getMegaForm",self)
    return v!=nil
  end
  
  def hasPrimalForm?
    v=MultipleForms.call("getPrimalForm",self)
    return v!=nil
  end
  
  def isMega?
    v=MultipleForms.call("getMegaForm",self)
    return v!=nil && v==@form
  end
  
  def isPrimal?
    v=MultipleForms.call("getPrimalForm",self)
    return v!=nil && v==@form
  end

  def makeMega
    v=MultipleForms.call("getMegaForm",self)
    self.form=v if v!=nil
  end
  
  def makePrimal
    v=MultipleForms.call("getPrimalForm",self)
    self.form=v if v!=nil
  end

  def makeUnmega
    v=MultipleForms.call("getUnmegaForm",self)
    self.form=v if v!=nil
  end
  
  def makeUnprimal
    v=MultipleForms.call("getUnprimalForm",self)
    self.form=v if v!=nil
  end

  def megaName
    v=MultipleForms.call("getMegaName",self)
    return v if v!=nil
    return ""
  end
  
  def primalName
    v=MultipleForms.call("getPrimalForm",self)
    return v if v!=nil
    return ""
  end
  
  def hasMegaMessage?(owner)
    v=MultipleForms.call("getMegaMessage",self,owner)
    return v!=nil
  end
  
  def getMegaMessage(owner)
    v=MultipleForms.call("getMegaMessage",self,owner)
    return v if v!=nil
    return ""
  end
  
  alias __mf_baseStats baseStats
  alias __mf_ability ability
  alias __mf_type1 type1
  alias __mf_type2 type2
  alias __mf_weight weight
  alias __mf_getMoveList getMoveList
  alias __mf_wildHoldItems wildHoldItems
  alias __mf_baseExp baseExp
  alias __mf_evYield evYield
  alias __mf_initialize initialize

  def baseStats
    v=MultipleForms.call("getBaseStats",self)
    return v if v!=nil
    return self.__mf_baseStats
  end

  def ability
    v=MultipleForms.call("ability",self)
    return v if v!=nil
    return self.__mf_ability
  end

  def type1
    v=MultipleForms.call("type1",self)
    return v if v!=nil
    return self.__mf_type1
  end

  def type2
    v=MultipleForms.call("type2",self)
    return v if v!=nil
    return self.__mf_type2
  end

  def weight
    v=MultipleForms.call("weight",self)
    return v if v!=nil
    return self.__mf_weight
  end

  def getMoveList
    v=MultipleForms.call("getMoveList",self)
    return v if v!=nil
    return self.__mf_getMoveList
  end

  def wildHoldItems
    v=MultipleForms.call("wildHoldItems",self)
    return v if v!=nil
    return self.__mf_wildHoldItems
  end

  def baseExp
    v=MultipleForms.call("baseExp",self)
    return v if v!=nil
    return self.__mf_baseExp
  end

  def evYield
    v=MultipleForms.call("evYield",self)
    return v if v!=nil
    return self.__mf_evYield
  end

  def initialize(*args)
    __mf_initialize(*args)
    f=MultipleForms.call("getFormOnCreation",self)
    if f
      self.form=f
      self.resetMoves
    end
  end
end



class PokeBattle_RealBattlePeer
  def pbOnEnteringBattle(battle,pokemon)
    f=MultipleForms.call("getFormOnEnteringBattle",pokemon)
    if f
      pokemon.form=f
    end
  end
end



module MultipleForms
  @@formSpecies=HandlerHash.new(:PBSpecies)

  def self.copy(sym,*syms)
    @@formSpecies.copy(sym,*syms)
  end

  def self.register(sym,hash)
    @@formSpecies.add(sym,hash)
  end

  def self.registerIf(cond,hash)
    @@formSpecies.addIf(cond,hash)
  end

  def self.hasFunction?(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return sp && sp[func]
  end

  def self.getFunction(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return (sp && sp[func]) ? sp[func] : nil
  end

  def self.call(func,pokemon,*args)
    sp=@@formSpecies[pokemon.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pokemon,*args)
  end
end



def drawSpot(bitmap,spotpattern,x,y,red,green,blue)
  height=spotpattern.length
  width=spotpattern[0].length
  for yy in 0...height
    spot=spotpattern[yy]
    for xx in 0...width
      if spot[xx]==1
        xOrg=(x+xx)<<1
        yOrg=(y+yy)<<1
        color=bitmap.get_pixel(xOrg,yOrg)
        r=color.red+red
        g=color.green+green
        b=color.blue+blue
        color.red=[[r,0].max,255].min
        color.green=[[g,0].max,255].min
        color.blue=[[b,0].max,255].min
        bitmap.set_pixel(xOrg,yOrg,color)
        bitmap.set_pixel(xOrg+1,yOrg,color)
        bitmap.set_pixel(xOrg,yOrg+1,color)
        bitmap.set_pixel(xOrg+1,yOrg+1,color)
      end   
    end
  end
end

def pbSpindaSpots(pokemon,bitmap)
  spot1=[
     [0,0,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,0,0]
  ]
  spot2=[
     [0,0,1,1,1,0,0],
     [0,1,1,1,1,1,0],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [0,1,1,1,1,1,0],
     [0,0,1,1,1,0,0]
  ]
  spot3=[
     [0,0,0,0,0,1,1,1,1,0,0,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot4=[
     [0,0,0,0,1,1,1,0,0,0,0,0],
     [0,0,1,1,1,1,1,1,1,0,0,0],
     [0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id=pokemon.personalID
  h=(id>>28)&15
  g=(id>>24)&15
  f=(id>>20)&15
  e=(id>>16)&15
  d=(id>>12)&15
  c=(id>>8)&15
  b=(id>>4)&15
  a=(id)&15
  if pokemon.isShiny?
    drawSpot(bitmap,spot1,b+33,a+25,-75,-10,-150)
    drawSpot(bitmap,spot2,d+21,c+24,-75,-10,-150)
    drawSpot(bitmap,spot3,f+39,e+7,-75,-10,-150)
    drawSpot(bitmap,spot4,h+15,g+6,-75,-10,-150)
  else
    drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75)
    drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75)
    drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75)
    drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75)
  end
end

MultipleForms.register(:UNOWN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(28)
}
})

MultipleForms.register(:SPINDA,{
"alterBitmap"=>proc{|pokemon,bitmap|
   pbSpindaSpots(pokemon,bitmap)
}
})

MultipleForms.register(:CASTFORM,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0              # Normal Form
   case pokemon.form
     when 1; next getID(PBTypes,:FIRE)  # Sunny Form
     when 2; next getID(PBTypes,:WATER) # Rainy Form
     when 3; next getID(PBTypes,:ICE)   # Snowy Form
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Normal Form
   case pokemon.form
     when 1; next getID(PBTypes,:FIRE)  # Sunny Form
     when 2; next getID(PBTypes,:WATER) # Rainy Form
     when 3; next getID(PBTypes,:ICE)   # Snowy Form
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DEOXYS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal Forme
   case pokemon.form
     when 1; next [50,180, 20,150,180, 20] # Attack Forme
     when 2; next [50, 70,160, 90, 70,160] # Defense Forme
     when 3; next [50, 95, 90,180, 95, 90] # Speed Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # Normal Forme
   case pokemon.form
     when 1; next [0,2,0,0,1,0] # Attack Forme
     when 2; next [0,0,2,0,0,1] # Defense Forme
     when 3; next [0,0,0,3,0,0] # Speed Forme
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
                        [25,:TAUNT],[33,:PURSUIT],[41,:PSYCHIC],[49,:SUPERPOWER],
                        [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:COSMICPOWER],
                        [81,:ZAPCANNON],[89,:PSYCHOBOOST],[97,:HYPERBEAM]]
     when 2 ; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
                        [25,:KNOCKOFF],[33,:SPIKES],[41,:PSYCHIC],[49,:SNATCH],
                        [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:IRONDEFENSE],
                        [73,:AMNESIA],[81,:RECOVER],[89,:PSYCHOBOOST],
                        [97,:COUNTER],[97,:MIRRORCOAT]]
     when 3 ; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:DOUBLETEAM],
                        [25,:KNOCKOFF],[33,:PURSUIT],[41,:PSYCHIC],[49,:SWIFT],
                        [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:AGILITY],
                        [81,:RECOVER],[89,:PSYCHOBOOST],[97,:EXTREMESPEED]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BURMY,{
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand ||
         env==PBEnvironment::Rock ||
         env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"getFormOnEnteringBattle"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand ||
         env==PBEnvironment::Rock ||
         env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:WORMADAM,{
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
      env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0               # Plant Cloak
   case pokemon.form
     when 1; next getID(PBTypes,:GROUND) # Sandy Cloak
     when 2; next getID(PBTypes,:STEEL)  # Trash Cloak
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0              # Plant Cloak
   case pokemon.form
     when 1; next [60,79,105,36,59, 85] # Sandy Cloak
     when 2; next [60,69, 95,36,69, 95] # Trash Cloak
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # Plant Cloak
   case pokemon.form
     when 1; next [0,0,2,0,0,0] # Sandy Cloak
     when 2; next [0,0,1,0,0,1] # Trash Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
                        [23,:CONFUSION],[26,:ROCKBLAST],[29,:HARDEN],[32,:PSYBEAM],
                        [35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],[44,:PSYCHIC],
                        [47,:FISSURE]]
     when 2 ; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
                        [23,:CONFUSION],[26,:MIRRORSHOT],[29,:METALSOUND],
                        [32,:PSYBEAM],[35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],
                        [44,:PSYCHIC],[47,:IRONHEAD]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

MultipleForms.register(:SHELLOS,{
"getFormOnCreation"=>proc{|pokemon|
   maps=[2,5,39,41,44,69]   # Map IDs for second form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
}
})

MultipleForms.copy(:SHELLOS,:GASTRODON)

MultipleForms.register(:ROTOM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Normal Form
   next [50,65,107,86,105,107] # All alternate forms
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0               # Normal Form
   case pokemon.form
     when 1; next getID(PBTypes,:FIRE)   # Heat, Microwave
     when 2; next getID(PBTypes,:WATER)  # Wash, Washing Machine
     when 3; next getID(PBTypes,:ICE)    # Frost, Refrigerator
     when 4; next getID(PBTypes,:FLYING) # Fan
     when 5; next getID(PBTypes,:GRASS)  # Mow, Lawnmower
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves=[
      :OVERHEAT,  # Heat, Microwave
      :HYDROPUMP, # Wash, Washing Machine
      :BLIZZARD,  # Frost, Refrigerator
      :AIRSLASH,  # Fan
      :LEAFSTORM  # Mow, Lawnmower
   ]
   hasoldmove=-1
   for i in 0...4
     for j in 0...moves.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves[j])
         hasoldmove=i; break
       end
     end
     break if hasoldmove>=0
   end
   if form>0
     newmove=moves[form-1]
     if newmove!=nil && hasConst?(PBMoves,newmove)
       if hasoldmove>=0
         # Automatically replace the old form's special move with the new one's
         oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
         newmovename=PBMoves.getName(getID(PBMoves,newmove))
         pokemon.moves[hasoldmove]=PBMove.new(getID(PBMoves,newmove))
         Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename))
         Kernel.pbMessage(_INTL("And...\1"))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[itemlevel]",pokemon.name,newmovename))
       else
         # Try to learn the new form's special move
         pbLearnMove(pokemon,getID(PBMoves,newmove),true)
       end
     end
   else
     if hasoldmove>=0
       # Forget the old form's special move
       oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
       pbDeleteMove(pokemon,hasoldmove)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:THUNDERSHOCK))
       end
     end
   end
}
})

MultipleForms.register(:GIRATINA,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:LEVITATE) # Origin Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 6500               # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Altered Forme
   next [150,120,100,90,120,100] # Origin Forme
},
"getForm"=>proc{|pokemon|
   maps=[49,50,51,72,73]   # Map IDs for Origin Forme
   if isConst?(pokemon.item,PBItems,:GRISEOUSORB) ||
      ($game_map && maps.include?($game_map.map_id))
     next 1
   end
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SHAYMIN,{
"type2"=>proc{|pokemon|
   next if pokemon.form==0     # Land Forme
   next getID(PBTypes,:FLYING) # Sky Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0              # Land Forme
   next getID(PBAbilities,:SERENEGRACE) # Sky Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next 52                 # Sky Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [100,103,75,127,120,75] # Sky Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next [0,0,0,3,0,0]      # Sky Forme
},
"getForm"=>proc{|pokemon|
   next 0 if PBDayNight.isNight?(pbGetTimeNow) ||
             pokemon.hp<=0 || pokemon.status==PBStatuses::FROZEN
   next nil
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:GROWTH],[10,:MAGICALLEAF],[19,:LEECHSEED],
                        [28,:QUICKATTACK],[37,:SWEETSCENT],[46,:NATURALGIFT],
                        [55,:WORRYSEED],[64,:AIRSLASH],[73,:ENERGYBALL],
                        [82,:SWEETKISS],[91,:LEAFSTORM],[100,:SEEDFLARE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ARCEUS,{
"type1"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK]
   next getID(PBTypes,types[pokemon.form])
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK]
   next getID(PBTypes,types[pokemon.form])
},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:FISTPLATE)
   next 2  if isConst?(pokemon.item,PBItems,:SKYPLATE)
   next 3  if isConst?(pokemon.item,PBItems,:TOXICPLATE)
   next 4  if isConst?(pokemon.item,PBItems,:EARTHPLATE)
   next 5  if isConst?(pokemon.item,PBItems,:STONEPLATE)
   next 6  if isConst?(pokemon.item,PBItems,:INSECTPLATE)
   next 7  if isConst?(pokemon.item,PBItems,:SPOOKYPLATE)
   next 8  if isConst?(pokemon.item,PBItems,:IRONPLATE)
   next 10 if isConst?(pokemon.item,PBItems,:FLAMEPLATE)
   next 11 if isConst?(pokemon.item,PBItems,:SPLASHPLATE)
   next 12 if isConst?(pokemon.item,PBItems,:MEADOWPLATE)
   next 13 if isConst?(pokemon.item,PBItems,:ZAPPLATE)
   next 14 if isConst?(pokemon.item,PBItems,:MINDPLATE)
   next 15 if isConst?(pokemon.item,PBItems,:ICICLEPLATE)
   next 16 if isConst?(pokemon.item,PBItems,:DRACOPLATE)
   next 17 if isConst?(pokemon.item,PBItems,:DREADPLATE)
   next 18 if isConst?(pokemon.item,PBItems,:PIXIEPLATE)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BASCULIN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(2)
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Red-Striped
   next [0,getID(PBItems,:DEEPSEASCALE),0] # Blue-Striped
}
})

MultipleForms.register(:DARMANITAN,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Standard Mode
   next [105,30,105,55,140,105] # Zen Mode
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Standard Mode
   next getID(PBTypes,:PSYCHIC) # Zen Mode
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Standard Mode
   next [0,0,0,0,2,0]      # Zen Mode
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DEERLING,{
"getForm"=>proc{|pokemon|
   time=pbGetTimeNow
   next (time.month-1)%4
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.copy(:DEERLING,:SAWSBUCK)

MultipleForms.register(:TORNADUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,100,80,121,110,90] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0                # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next getID(PBAbilities,:REGENERATOR) # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,3,0,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:THUNDURUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,105,70,101,145,80] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0               # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next getID(PBAbilities,:VOLTABSORB) # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,0,3,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LANDORUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0    # Incarnate Forme
   next [89,145,90,71,105,80] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0               # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next getID(PBAbilities,:INTIMIDATE) # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,3,0,0,0,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:KYUREM,{
"getBaseStats"=>proc{|pokemon|
   case pokemon.form
     when 1; next [125,120, 90,95,170,100] # White Kyurem
     when 2; next [125,170,100,95,120, 90] # Black Kyurem
     else;   next                          # Kyurem
   end
},
"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next getID(PBAbilities,:TURBOBLAZE) # White Kyurem
     when 2; next getID(PBAbilities,:TERAVOLT)   # Black Kyurem
     else;   next                                # Kyurem
   end
},
"evYield"=>proc{|pokemon|
   case pokemon.form
     when 1; next [0,0,0,0,3,0] # White Kyurem
     when 2; next [0,3,0,0,0,0] # Black Kyurem
     else;   next               # Kyurem
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
                       [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
                       [36,:SLASH],[43,:FUSIONFLARE],[50,:ICEBURN],
                       [57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
                       [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
     when 2; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
                       [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
                       [36,:SLASH],[43,:FUSIONBOLT],[50,:FREEZESHOCK],
                       [57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
                       [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:KELDEO,{
"getForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:SECRETSWORD) # Resolute Form
   next 0                                     # Ordinary Form
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:MELOETTA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [100,128,90,128,77,77] # Pirouette Forme
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0       # Aria Forme
   next getID(PBTypes,:FIGHTING) # Pirouette Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Aria Forme
   next [0,1,1,1,0,0]      # Pirouette Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GENESECT,{
"getForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SHOCKDRIVE)
   next 2 if isConst?(pokemon.item,PBItems,:BURNDRIVE)
   next 3 if isConst?(pokemon.item,PBItems,:CHILLDRIVE)
   next 4 if isConst?(pokemon.item,PBItems,:DOUSEDRIVE)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:MEOWSTIC,{
"ability"=>proc{|pokemon|
   next if pokemon.gender==0              # Male Meowstic
   if pokemon.abilityflag && pokemon.abilityflag=2
     next getID(PBAbilities,:COMPETITIVE) # Female Meowstic
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.gender==0                                # Male Meowstic
   movelist=[]
   case pokemon.gender
     when 1 ; movelist=[[1,:STOREDPOWER],[1,:MEFIRST],[1,:MAGICALLEAF],[1,:SCRATCH],
                        [1,:LEER],[5,:COVET],[9,:CONFUSION],[13,:LIGHTSCREEN],
                        [17,:PSYBEAM],[19,:FAKEOUT],[25,:PSYSHOCK],[28,:CHARGEBEAM],
                        [31,:SHADOWBALL],[35,:EXTRASENSORY],[40,:PSYCHIC],
                        [43,:ROLEPLAY],[45,:SIGNALBEAM],[48,:SUCKERPUNCH],
                        [50,:FUTURESIGHT],[53,:STOREDPOWER]] # Female Meowstic 
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

MultipleForms.register(:AEGISLASH,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Shield Form
   next [60,150,50,60,150,50] if pokemon.form==1    # Blade Form
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:PUMPKABOO,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(4)
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Average Size
   case pokemon.form
     when 1; next [44,66,70,56,44,55] # Small Size
     when 2; next [54,66,70,46,44,55] # Large Size
     when 3; next [59,66,70,41,44,55] # Super Size
   end
}
})

MultipleForms.register(:GOURGEIST,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(4)
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0              # Average Size
   case pokemon.form
     when 1; next [55,85,122,99,58,75]  # Small Size
     when 2; next [75,95,122,69,58,75]  # Large Size
     when 3; next [85,100,122,54,58,75] # Super Size
   end
}
})

MultipleForms.register(:HOOPA,{
"getForm"=>proc{|pokemon|
   next 0 if ((pbGetTimeNow-pokemon.form_change_time)/60/60/24)>3 || 
       !($Trainer.party).include?(pokemon)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DARK) if pokemon.form==1 # Unbound Forme
},
"height"=>proc{|pokemon|
   next 65 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 490 if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,160,60,80,170,130] if pokemon.form==1 # Unbound Forme
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:TRICK],[1,:DESTINYBOND],[5,:ALLYSWITCH],[10,:CONFUSION],
                        [12,:ASTONISH],[15,:MAGICCOAT],[21,:PSYBEAM],[25,:LIGHTSCREEN],
                        [29,:SKILLSWAP],[35,:GUARDSPLIT],[42,:PHANTOMFORCE],
                        [47,:WONDERROOM],[53,:TRICKROOM],[57,:SHADOWBALL],[60,:PSYCHIC],
                        [80,:HYPERSPACEFURY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

##### Mega Evolution forms #####################################################

MultipleForms.register(:VENUSAUR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:VENUSAURITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Venusaur") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,100,123,80,122,120] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:THICKFAT) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 24 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1555 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:CHARIZARD,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CHARIZARDITEX)
   next 2 if isConst?(pokemon.item,PBItems,:CHARIZARDITEY)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Charizard X") if pokemon.form==1
   next _INTL("Mega Charizard Y") if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [78,130,111,100,130,85] if pokemon.form==1
   next [78,104,78,100,159,115] if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DRAGON) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==1
   next getID(PBAbilities,:DROUGHT) if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 1105 if pokemon.form==1
   next 1005 if pokemon.form==2
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BLASTOISE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BLASTOISINITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Blastoise") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [79,103,120,78,135,115] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:MEGALAUNCHER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1011 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GYARADOS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GYARADOSITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Gyarados") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,155,109,81,70,130] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DARK) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:MOLDBREAKER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 305 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:HOUNDOOM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:HOUNDOOMITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Houndoom") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,90,90,115,140,90] if pokemon.form==1
   next
},

"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SOLARPOWER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 49.5 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:ALAKAZAM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ALAKAZITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Alakazam") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [55,50,65,150,175,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:TRACE) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 485 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:GENGAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GENGARITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Gengar") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,65,80,130,170,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SHADOWTAG) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 480 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:KANGASKHAN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:KANGASKHANITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Kangaskhan") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [105,125,100,100,60,100] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:PARENTALBOND) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1000 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:PINSIR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:PINSIRITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Pinsir") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,155,105,120,65,90] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:AERILATE) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 590 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:AERODACTYL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:AERODACTYLITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Aerodactyl") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,135,85,150,70,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 790 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:MEWTWO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MEWTWONITEX)
   next 2 if isConst?(pokemon.item,PBItems,:MEWTWONITEY)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Mewtwo X") if pokemon.form==1
   next _INTL("Mega Mewtwo Y") if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [106,190,100,130,154,100] if pokemon.form==1
   next [106,150,70,140,194,120] if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIGHTING) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:STEADFAST) if pokemon.form==1
   next getID(PBAbilities,:INSOMNIA) if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 1270 if pokemon.form==1
   next 330 if pokemon.form==2
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:AMPHAROS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:AMPHAROSITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Ampharos") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [90,95,105,45,165,110] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DRAGON) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:MOLDBREAKER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 615 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:SCIZOR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SCIZORITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Scizor") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,150,140,75,65,100] if pokemon.form==1
   next
},

"ability"=>proc{|pokemon|
   next getID(PBAbilities,:TECHNICIAN) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1250 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:HERACROSS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:HERACRONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Heracross") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,185,115,75,40,105] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SKILLLINK) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 625 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:TYRANITAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:TYRANITARITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Tyranitar") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,164,150,71,95,120] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SANDSTREAM) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 2550 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:BLAZIKEN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BLAZIKENITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Blaziken") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,160,80,100,130,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SPEEDBOOST) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 520 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:GARDEVOIR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GARDEVOIRITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Gardevoir") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [68,85,65,100,165,135] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:PIXILATE) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 484 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:MAWILE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MAWILITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Mawile") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,105,125,50,55,95] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FAIRY) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:HUGEPOWER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 235 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:AGGRON,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:AGGRONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Aggron") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,140,230,50,60,80] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:STEEL) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:FILTER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3950 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:MEDICHAM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MEDICHAMITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Medicham") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,100,85,100,80,85] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:PUREPOWER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 315 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:MANECTRIC,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MANECTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Manectric") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,75,80,135,135,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:INTIMIDATE) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 440 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:BANETTE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BANETTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Banette") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [64,165,75,75,93,83] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:PRANKSTER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 130 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:ABSOL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ABSOLITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Absol") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,150,60,115,115,60] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 490 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GARCHOMP,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GARCHOMPITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Garchomp") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [108,170,115,92,120,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SANDFORCE) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 950 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:LUCARIO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:LUCARIONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Lucario") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,145,88,112,140,70] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:ADAPTABILITY) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 575 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:ABOMASNOW,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ABOMASITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Abomasnow") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [90,132,105,30,132,105] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SNOWWARNING) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1850 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BEEDRILL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BEEDRILLITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Beedrill") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,150,40,145,15,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:ADAPTABILITY) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 14 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 40.5 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:PIDGEOT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:PIDGEOTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Pidgeot") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [83,80,80,121,135,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:NOGUARD) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 22 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 50.5 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SLOWBRO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SLOWBRONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Slowbro") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,75,180,30,130,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SHELLARMOR) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 120 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:STEELIX,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:STEELIXITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Steelix") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,125,230,30,55,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SANDFORCE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 105 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 740 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SCEPTILE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SCEPTILITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Sceptile") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,110,70,145,145,85] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:LIGHTNINGROD) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 19 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 55.2 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SWAMPERT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SWAMPERTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Swampert") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,150,110,70,85,110] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SWIFTSWIM) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 19 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 102 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SABLEYE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SABLENITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Sableye") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,85,125,20,85,115] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 5 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 161 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SHARPEDO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SHARPEDONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Sharpedo") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,140,70,105,110,65] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:STRONGJAW) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 130.3 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:CAMERUPT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CAMERUPTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Camerupt") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,120,100,20,145,105] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SHEERFORCE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 320.5 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ALTARIA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ALTARIANITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Altaria") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,110,100,80,110,105] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FAIRY) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:PIXILATE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 15 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 206 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GLALIE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GLALITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Glalie") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,120,80,100,120,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:REFRIGERATE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 21 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 350.2 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SALAMENCE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SALAMENCITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Salamence") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,145,130,120,120,90] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:AERILATE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 18 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 112.5 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:METAGROSS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:METAGROSSITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Metagross") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,145,150,110,105,110] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 942.9 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LATIAS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:LATIASITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Latias") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,100,120,110,140,150] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:LEVITATE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 18 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 52 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LATIOS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:LATIOSITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Latios") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,130,100,110,160,120] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:LEVITATE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 23 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 70 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:LOPUNNY,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:LOPUNNITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Lopunny") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,136,94,135,54,96] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIGHTING) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:SCRAPPY) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 13 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 28.3 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GALLADE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GALLADITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Gallade") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [68,165,95,110,65,115] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:INNERFOCUS) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 16 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 56.4 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:AUDINO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:AUDINITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Audino") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [103,60,126,50,80,126] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FAIRY) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:HEALER) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 15 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 32 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DIANCIE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:DIANCITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Diancie") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,160,110,110,160,110] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 11 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 27.8 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:RAYQUAZA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:DRAGONASCENT)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Rayquaza") if pokemon.form==1
   next
},
"getMegaMessage"=>proc{|pokemon,owner|
   if owner==$Trainer
     next _INTL("{1}'s fervent wish has reached {2}!",owner.name,pokemon.name)
   else
     next _INTL("{1} has reacted to {2}'s fervent wish!",pokemon.name,owner.name)
   end
},
"getBaseStats"=>proc{|pokemon|
   next [105,180,100,115,180,100] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:DELTASTREAM) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 108 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 392 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:KYOGRE,{
"getPrimalForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BLUEORB)# && pokemon.form==0
   next 
},
"getUnprimalForm"=>proc{|pokemon|
   next 0
},
"getPrimalName"=>proc{|pokemon|
   next _INTL("Primal Kyogre") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,150,90,90,180,160] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:PRIMORDIALSEA) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 98 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 4300 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GROUDON,{
"getPrimalForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:REDORB)# && pokemon.form==0
   next 
},
"getUnprimalForm"=>proc{|pokemon|
   next 0
},
"getPrimalName"=>proc{|pokemon|
   next _INTL("Primal Groudon") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,180,160,90,150,90] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIRE) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:DESOLATELAND) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 50 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 9997 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getOffsetY"=>proc{|pokemon|
  next -50 if pokemon.form==1
}
})