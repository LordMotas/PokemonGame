#===============================================================================
#                              *Item Crafter
# *Item Crafter scene created by TheKrazyGamer/kcgcrazy/TheKraazyGamer
# *Please Give Credit if used
#
# *In order to unlock an item recipe use $canCraft[x]=true  where x is the 
#  element of the @item array
#
# *to add an item of your own just add it to the @items array
#  Then add its required materials to the @materials array
#  under *case @item* add another *when x* where x is the next number
#  Here is an example
#        when 0
#          if $canCraft[@item]
#            @sprites["unknown"].opacity=0
#            @sprites["Item_icon"].opacity=255
#            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
#            @sprites["Item_1_icon"].opacity=255
#            @sprites["Item_2_icon"].opacity=0
#            @mat1=0
#            @mat2=-1
#            @cost1=2
#            @cost2=0
#            @amount=3
#          else
#            @sprites["unknown"].opacity=255
#            @sprites["Item_icon"].opacity=0
#            @sprites["Item_1_icon"].opacity=0
#            @sprites["Item_2_icon"].opacity=0
#          end
#          self.text
#  *@materials[3]* is whatever element your material is - duh
#  if there is only one required material -
#  make *@sprites["Item_2_icon"].setBitmap("")*
#  and make *@mat2=-1*
#  
#  *To change the amount of materials required change @cost1 and @cost2 to the 
#    Desired cost. To change the amount made change @amount
#
#  Change *if Input.trigger?(Input::RIGHT)  && @item <17* to
#  *if Input.trigger?(Input::RIGHT)  && @item <XX* where XX is the amount of 
#  elements in the @items array - currently (0-17) total of 18 items
#
# *To call put ItemCrafterScene.new in an event
#  or create an item like this
#
#  #Item Crafter
#  ItemHandlers::UseFromBag.add(:ITEMCRAFTER,proc{|item|
#      Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
#        ItemCrafterScene.new
#      next 1
#    })
#  and add this to the Items.txt : 634,ITEMCRAFTER,Item Crafter,8,0,"Lets you craft items.",2,0,6,
#
# *I know that this can probably be tidied up so please dont hate on me for that
#===============================================================================

$exit = 0  

$canCraft = [false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false] 
                


class ItemCrafterScene


  
  def initialize
    @close = $exit
    @select=1
    @item=0
    @mat1=0# the amount for the first item made - when 0
    @mat2=-1# the amount for the first item made - when 0
    @cost1=2# the amount for the first item made - when 0
    @cost2=0# the amount for the first item made - when 0
    @amount=3 # the amount for the first item made - when 0
    @items = [PBItems::POKEBALL,
              PBItems::GREATBALL,
              PBItems::ULTRABALL,
              PBItems::DIVEBALL,
              PBItems::DUSKBALL,
              PBItems::FASTBALL,
              PBItems::FRIENDBALL,
              PBItems::HEALBALL,
              PBItems::HEAVYBALL,
              PBItems::LEVELBALL,
              PBItems::LOVEBALL,
              PBItems::LUXURYBALL,
              PBItems::MOONBALL,
              PBItems::NESTBALL,
              PBItems::NETBALL,
              PBItems::PREMIERBALL,
              PBItems::REPEATBALL,
              PBItems::TIMERBALL]
              
    @materials = [PBItems::REDAPRICORN,
                  PBItems::YLWAPRICORN,
                  PBItems::BLUAPRICORN,
                  PBItems::GRNAPRICORN,
                  PBItems::PNKAPRICORN,
                  PBItems::WHTAPRICORN,
                  PBItems::BLKAPRICORN]
    
                
                  
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}

    @sprites["bg"]=IconSprite.new(0,0,@viewport)    
    @sprites["bg"].setBitmap("Graphics/Pictures/ItemCrafter/BG")
    
    @sprites["Item"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item"].setBitmap("Graphics/Pictures/ItemCrafter/Item_BG")
    @sprites["Item"].x=210+10
    @sprites["Item"].y=30
    
    @sprites["Item_Hov"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_Hov"].setBitmap("Graphics/Pictures/ItemCrafter/ItemHov_BG")
    @sprites["Item_Hov"].x=210+10
    @sprites["Item_Hov"].y=30
    @sprites["Item_Hov"].opacity=0
    
    @sprites["Item_icon"]=IconSprite.new(0,0,@viewport)  
    @sprites["Item_icon"].setBitmap(pbItemIconFile(@items[@item]))
    @sprites["Item_icon"].x=220+10
    @sprites["Item_icon"].y=40
    @sprites["Item_icon"].opacity=0
    
    @sprites["unknown"]=IconSprite.new(0,0,@viewport)    
    @sprites["unknown"].setBitmap("Graphics/Pictures/ItemCrafter/unknown")
    @sprites["unknown"].x=220
    @sprites["unknown"].y=30
    
    @sprites["Item_1"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_1"].setBitmap("Graphics/Pictures/ItemCrafter/ItemR_BG")
    @sprites["Item_1"].x=65
    @sprites["Item_1"].y=100
    
    @sprites["Item_1_icon"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
    @sprites["Item_1_icon"].x=65+10
    @sprites["Item_1_icon"].y=100+10
    @sprites["Item_1_icon"].opacity=0
    
    @sprites["Item_1_name"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_1_name"].setBitmap("Graphics/Pictures/ItemCrafter/Item_Name")
    @sprites["Item_1_name"].x=140
    @sprites["Item_1_name"].y=110
    
    @sprites["Item_2"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_2"].setBitmap("Graphics/Pictures/ItemCrafter/ItemR_BG")
    @sprites["Item_2"].x=65
    @sprites["Item_2"].y=185
    
    @sprites["Item_2_icon"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[0]))
    @sprites["Item_2_icon"].x=65+10
    @sprites["Item_2_icon"].y=185+10
    @sprites["Item_2_icon"].opacity=0
    
    @sprites["Item_2_name"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_2_name"].setBitmap("Graphics/Pictures/ItemCrafter/Item_Name")
    @sprites["Item_2_name"].x=140
    @sprites["Item_2_name"].y=198
    
    @sprites["Confirm"]=IconSprite.new(0,0,@viewport)    
    @sprites["Confirm"].setBitmap("Graphics/Pictures/ItemCrafter/Selection")
    @sprites["Confirm"].x=115
    @sprites["Confirm"].y=280
    
    @sprites["Confirm_Hov"]=IconSprite.new(0,0,@viewport)    
    @sprites["Confirm_Hov"].setBitmap("Graphics/Pictures/ItemCrafter/Selection_1")
    @sprites["Confirm_Hov"].x=115
    @sprites["Confirm_Hov"].y=280
    @sprites["Confirm_Hov"].opacity=0
    
    @sprites["Cancel"]=IconSprite.new(0,0,@viewport)    
    @sprites["Cancel"].setBitmap("Graphics/Pictures/ItemCrafter/Selection")
    @sprites["Cancel"].x=115
    @sprites["Cancel"].y=330
    
    @sprites["Cancel_Hov"]=IconSprite.new(0,0,@viewport)    
    @sprites["Cancel_Hov"].setBitmap("Graphics/Pictures/ItemCrafter/Selection_1")
    @sprites["Cancel_Hov"].x=115
    @sprites["Cancel_Hov"].y=330

    @sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    
    self.openItemCrafterscene
  end
  
  def openItemCrafterscene
    self.CheckAbleToCraft
    pbFadeInAndShow(@sprites) {self.text}
    self.input
    self.action
  end
  
  def closeItemCrafterscene
    pbFadeOutAndHide(@sprites)  
  end
    
    def input
      case @select
      when 1
        @sprites["Confirm"].opacity=255
        @sprites["Confirm_Hov"].opacity=0
        @sprites["Cancel"].opacity=0
        @sprites["Cancel_Hov"].opacity=255
        @sprites["Item"].opacity=255
        @sprites["Item_Hov"].opacity=0
      when 2
        @sprites["Confirm"].opacity=0
        @sprites["Confirm_Hov"].opacity=255
        @sprites["Cancel"].opacity=255
        @sprites["Cancel_Hov"].opacity=0
        @sprites["Item"].opacity=255
        @sprites["Item_Hov"].opacity=0
      when 3
        @sprites["Confirm"].opacity=255
        @sprites["Confirm_Hov"].opacity=0
        @sprites["Cancel"].opacity=255
        @sprites["Cancel_Hov"].opacity=0
        @sprites["Item"].opacity=0
        @sprites["Item_Hov"].opacity=255
        @sprites["Item_icon"].setBitmap(pbItemIconFile(@items[@item]))
        case @item
        when 0
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=0
            @mat1=0
            @mat2=-1
            @cost1=2
            @cost2=0
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 1
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[2]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=0
            @mat2=2
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 2
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[6]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[1]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=6
            @mat2=1
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 3
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[4]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[2]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=4
            @mat2=2
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 4
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[6]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[3]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=6
            @mat2=3
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 5
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[1]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=0
            @mat2=1
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 6
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[3]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[1]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=3
            @mat2=1
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 7
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[4]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[5]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=4
            @mat2=5
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 8
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[2]))
            @sprites["Item_2_icon"].setBitmap("")
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=2
            @mat2=-1
            @cost1=2
            @cost2=0
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 9
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[6]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[0]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=6
            @mat2=0
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 10
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[5]))
            @sprites["Item_2_icon"].setBitmap("")
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=5
            @mat2=-1
            @cost1=2
            @cost2=0
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 11
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[5]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=0
            @mat2=5
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 12
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[6]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[2]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=6
            @mat2=2
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 13
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[3]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[1]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=3
            @mat2=1
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 14
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[6]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[2]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=6
            @mat2=2
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 15
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[5]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=0
            @mat2=5
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 16
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[6]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=0
            @mat2=6
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        when 17
          if $canCraft[@item]
            @sprites["unknown"].opacity=0
            @sprites["Item_icon"].opacity=255
            @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[5]))
            @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[6]))
            @sprites["Item_1_icon"].opacity=255
            @sprites["Item_2_icon"].opacity=255
            @mat1=5
            @mat2=6
            @cost1=2
            @cost2=2
            @amount=3
          else
            @sprites["unknown"].opacity=255
            @sprites["Item_icon"].opacity=0
            @sprites["Item_1_icon"].opacity=0
            @sprites["Item_2_icon"].opacity=0
          end
          self.text
        end
        if Input.trigger?(Input::RIGHT)  && @item <17
          @item+=1
        end
        if Input.trigger?(Input::LEFT) && @item >0
          @item-=1
        end
      end    
      
      if Input.trigger?(Input::UP)  && @select <3
        @select+=1
      end
      if Input.trigger?(Input::DOWN) && @select >1
        @select-=1
      end
      
      if Input.trigger?(Input::C) 
        case @select
        when 2 
          if $canCraft[@item]
            if $PokemonBag.pbQuantity(@materials[@mat2])<@cost1 || $PokemonBag.pbQuantity(@materials[@mat1]) <@cost2
              Kernel.pbMessage(_INTL("Unable to craft item, you do not have the required materials"))
            else
              $PokemonBag.pbStoreItem(@items[@item],@amount)
              $PokemonBag.pbDeleteItem(@materials[@mat1],@cost1)
              if @mat2!=-1
                $PokemonBag.pbDeleteItem(@materials[@mat2],@cost2)
              end
              self.text
              Kernel.pbMessage(_INTL("{1} {2}'s were crafted", @amount, PBItems.getName(@items[@item])))
            end
          else
            Kernel.pbMessage(_INTL("You do not know this item's recipe"))
          end
        when 1
          @close=@select
          self.closeItemCrafterscene
        end      
      end
      
      if Input.trigger?(Input::B)
        @close=@select
        self.closeItemCrafterscene  
      end
      
    end
    
  def action
    while @close==0
      Graphics.update
      Input.update
      self.input
    end
  end
  
  def text
    overlay= @sprites["overlay"].bitmap
    overlay.clear
    baseColor=Color.new(255, 255, 255)
    shadowColor=Color.new(0,0,0)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    textos=[]
    if $canCraft[@item]
      @text1=_INTL("{1}/{2} {3}", $PokemonBag.pbQuantity(@materials[@mat1]),@cost1, PBItems.getName(@materials[@mat1]))
      if @mat2 < 0
        @text2=_INTL("")
      else
        @text2=_INTL("{1}/{2} ,  {3}", $PokemonBag.pbQuantity(@materials[@mat2]),@cost2 , PBItems.getName(@materials[@mat2]))
      end
    else
      @text1=_INTL("UNKOWN")
      @text2=_INTL("UNKOWN")
    end
    @text3=_INTL("{1} / {2}", @item + 1, @items.size)
    textos.push([@text1,175,115,false,baseColor,shadowColor])
    textos.push([@text2,175,198+5,false,baseColor,shadowColor])
    textos.push([@text3,75,30,false,baseColor,shadowColor])
    textos.push(["Craft",230,280+5,false,baseColor,shadowColor])
    textos.push(["Cancel",230,330+5,false,baseColor,shadowColor])
    pbDrawTextPositions(overlay,textos)
  end
  
  def CheckAbleToCraft
    if $canCraft[0]
      @sprites["Item_icon"].opacity=255
      @sprites["Item_1_icon"].opacity=255
      @sprites["unknown"].opacity=0
    else
      @sprites["Item_icon"].opacity=0
      @sprites["Item_1_icon"].opacity=0
      @sprites["unknown"].opacity=255
    end
  end
    
end