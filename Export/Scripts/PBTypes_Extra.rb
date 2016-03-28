class PBTypes
  @@TypeData=nil # internal

  def PBTypes.loadTypeData # internal
    if !@@TypeData
      @@TypeData=load_data("Data/types.dat")
      @@TypeData[0].freeze
      @@TypeData[1].freeze
      @@TypeData[2].freeze
      @@TypeData.freeze
    end
    return @@TypeData
  end

  def PBTypes.isPseudoType?(type)
    return PBTypes.loadTypeData()[0].include?(type)
  end

  def PBTypes.isSpecialType?(type)
    return PBTypes.loadTypeData()[1].include?(type)
  end

  def PBTypes.getEffectiveness(attackType,opponentType,inverse=false)
    ret=PBTypes.loadTypeData()[2][attackType*(PBTypes.maxValue+1)+opponentType]
    if inverse
      if ret==0 || ret==1
        ret=4
      elsif ret==4
        ret=1
      end
    end
    return ret
  end

  def PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2=nil,opponentType3=nil)
    if opponentType2==nil && opponentType3==nil
      return PBTypes.getEffectiveness(attackType,opponentType1)*2
    else
      mod3=2
      mod1=PBTypes.getEffectiveness(attackType,opponentType1)
      mod2=(opponentType1==opponentType2) ? 2 : PBTypes.getEffectiveness(attackType,opponentType2)
      mod3=(opponentType3==nil || opponentType3==opponentType2 || opponentType3==opponentType1)? 2: PBTypes.getEffectiveness(attackType,opponentType3)
      return ((mod1*mod2*mod3)/2)
    end
  end

  def PBTypes.isNotVeryEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e>0 && e<4
  end

  def PBTypes.isNormalEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e==4
  end

  def PBTypes.isIneffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e==0
  end

  def PBTypes.isSuperEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e>4
  end
end