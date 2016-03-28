def pbGetEvolvedFormData(species)
  ret=[]
  _EVOTYPEMASK=0x3F
  _EVODATAMASK=0xC0
  _EVONEXTFORM=0x00
  pbRgssOpen("Data/evolutions.dat","rb"){|f|
     f.pos=(species-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         evo=f.fgetb
         evonib=evo&_EVOTYPEMASK
         level=f.fgetw
         poke=f.fgetw
         if (evo&_EVODATAMASK)==_EVONEXTFORM
           ret.push([evonib,level,poke])
         end
         i+=5
       end
     end
  }
  return ret
end

def pbEvoDebug()
  _EVOTYPEMASK=0x3F
  _EVODATAMASK=0xC0
  pbRgssOpen("Data/evolutions.dat","rb"){|f|
     for species in 1..PBSpecies.maxValue
       f.pos=(species-1)*8
       offset=f.fgetdw
       length=f.fgetdw
       puts PBSpecies.getName(species)
       if length>0
         f.pos=offset
         i=0; loop do break unless i<length
           evo=f.fgetb
           evonib=evo&_EVOTYPEMASK
           level=f.fgetw
           poke=f.fgetw
           puts sprintf("type=%02X, data=%02X, name=%s, level=%d",
              evonib,evo&_EVODATAMASK,PBSpecies.getName(poke),level)
           if poke==0
             p f.eof?
             break
           end
           i+=5
         end
       end
     end
  }
end

def pbGetPreviousForm(species)
  _EVOTYPEMASK=0x3F
  _EVODATAMASK=0xC0
  _EVOPREVFORM=0x40
  pbRgssOpen("Data/evolutions.dat","rb"){|f|
     f.pos=(species-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         evo=f.fgetb
         evonib=evo&_EVOTYPEMASK
         level=f.fgetw
         poke=f.fgetw
         if (evo&_EVODATAMASK)==_EVOPREVFORM
           return poke
         end
         i+=5
       end
     end
  }
  return species
end

def pbGetMinimumLevel(species)
  ret=-1
  _EVOTYPEMASK=0x3F
  _EVODATAMASK=0xC0
  _EVOPREVFORM=0x40
  pbRgssOpen("Data/evolutions.dat","rb"){|f|
    f.pos=(species-1)*8
    offset=f.fgetdw
    length=f.fgetdw
    if length>0
      f.pos=offset
      i=0; loop do break unless i<length
        evo=f.fgetb
        evonib=evo&_EVOTYPEMASK
        level=f.fgetw
        poke=f.fgetw
        if poke<=PBSpecies.maxValue && 
           (evo&_EVODATAMASK)==_EVOPREVFORM && # evolved from
           [4,8,9,10,11,12,13,14,22,23].include?(evonib)
          ret=(ret==-1) ? level : [ret,level].min
          break
        end
        i+=5
      end
    end
  }
  return (ret==-1) ? 1 : ret
end

def pbGetBabySpecies(species)
  ret=species
  _EVOTYPEMASK=0x3F
  _EVODATAMASK=0xC0
  _EVOPREVFORM=0x40
  pbRgssOpen("Data/evolutions.dat","rb"){|f|
     f.pos=(species-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         evo=f.fgetb
         evonib=evo&_EVOTYPEMASK
         level=f.fgetw
         poke=f.fgetw
         if poke<=PBSpecies.maxValue && (evo&_EVODATAMASK)==_EVOPREVFORM # evolved from
           ret=poke
           break
         end
         i+=5
       end
     end
  }
  if ret!=species
    ret=pbGetBabySpecies(ret)
  end
  return ret
end