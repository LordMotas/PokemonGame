#==============================================================================
# %%%% Scene_PokeUraniumMenu %%%%
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
#Made by ~JV~
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#==============================================================================

class Menu
  
 # For Move animation

 def pbInfo(item)
    case item
    when "Pokedex"
      return "POKEDEX"
    when "Pokemon"
      return "POKEMON"
    when "Craft"
      return "CRAFT"
    when "Bag"
      return "BAG"
    when "I.D."
      return $Trainer.name
    when "Save"
      return "SAVE"
    when "Options"
      return "OPTIONS"
    when "Exit"
      return "EXIT"
    end
  end

 
def pbStartScene
    @done=false
    @index=0
    @oldindex=0
    @commands=[]

    @sprites={}
       
    @viewport=Viewport.new(0,0,Graphics.width, Graphics.height)
    @viewport.z=99999
    @sprites["bgback"]=IconSprite.new(0,0,@viewport)
    @sprites["bgback"].setBitmap("Graphics/Pictures/menuback")
    @sprites["bgback"].opacity=0
    
     for i in 0...6
     @sprites["box#{i}"]=Sprite.new(@viewport)
      @sprites["box#{i}"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/menupkbox")
      @sprites["box#{i}"].z=99999
      @sprites["box#{i}"].x=374+74*(i&1)
      @sprites["box#{i}"].y=108+72*(i/2)
       @sprites["box#{i}"].opacity=0
    end
     for i in 0...$Trainer.party.length
      @sprites["party#{i}"]=PokemonIconSprite.new($Trainer.party[i],@viewport)
      @sprites["party#{i}"].z=99999
      @sprites["party#{i}"].x=372+74*(i&1)
      @sprites["party#{i}"].y=100+72*(i/2)
      @sprites["party#{i}"].opacity=0
    end
if $Trainer.pokedex  && $game_variables[117] != 2
 @commands.push("Pokedex")
 @sprites["dex"]=IconSprite.new(20,0,@viewport)
 @sprites["dex"].setBitmap("Graphics/Pictures/menuico1")
 @sprites["dex"].opacity=0
end
if $Trainer.party.length>0  && $game_variables[117] != 2
 @commands.push("Pokemon")
 @sprites["pokemon"]=IconSprite.new(80,0,@viewport)
 @sprites["pokemon"].setBitmap("Graphics/Pictures/menuico2")
 @sprites["pokemon"].opacity=0
end
if  $game_variables[117] != 2
 @commands.push("Bag")
 @sprites["bag"]=IconSprite.new(140,0,@viewport)
 @sprites["bag"].setBitmap("Graphics/Pictures/menuico3")
 @sprites["bag"].opacity=0
end 
if $Trainer.itemCrafter && $game_variables[117] != 2
 @commands.push("Craft")
 @sprites["craft"]=IconSprite.new(200,0,@viewport)
 @sprites["craft"].setBitmap("Graphics/Pictures/menuico4")
 @sprites["craft"].opacity=0  
end

 
    @commands.push("I.D.")
    @commands.push("Save")
    @commands.push("Options")
    @commands.push("Exit")
     
 @sprites["card"]=IconSprite.new(260,0,@viewport)
 @sprites["card"].setBitmap("Graphics/Pictures/menuico5")
 @sprites["card"].opacity=0
 
 @sprites["save"]=IconSprite.new(320,0,@viewport)
 @sprites["save"].setBitmap("Graphics/Pictures/menuico6")
 @sprites["save"].opacity=0
 
 @sprites["options"]=IconSprite.new(380,0,@viewport)
 @sprites["options"].setBitmap("Graphics/Pictures/menuico7")
 @sprites["options"].opacity=0
 
 @sprites["exit"]=IconSprite.new(440,0,@viewport)
 @sprites["exit"].setBitmap("Graphics/Pictures/menuico8")
 @sprites["exit"].opacity=0
 
     @sprites["info"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
     pbSetSystemFont(@sprites["info"].bitmap)
 
pbOpenMenu
    updateSelection
  end
    
   def pbOpenMenu
    loop do
      Graphics.update
      Input.update
      @sprites["bgback"].opacity+=18
      @sprites["dex"].opacity+=18 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity+=18 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity+=18 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity+=18 if $game_variables[117] != 2
 @sprites["card"].opacity+=18
 @sprites["save"].opacity+=18
 @sprites["info"].opacity+=25.5
 @sprites["options"].opacity+=18
 @sprites["exit"].opacity+=18
  for i in 0...6
     @sprites["box#{i}"].opacity+=18
   end
   for i in 0...$Trainer.party.length
   @sprites["party#{i}"].opacity+=18
   end
      break if @sprites["bgback"].opacity==180
      end
    end
  
      def pbCloseMenu
    loop do
      Graphics.update
      Input.update
      @sprites["bgback"].opacity-=18
      @sprites["dex"].opacity-=18 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity-=18 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity-=18 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity-=18 if $game_variables[117] != 2
 @sprites["card"].opacity-=18
 @sprites["save"].opacity-=18
 @sprites["options"].opacity-=18
 @sprites["info"].opacity-=18
 @sprites["exit"].opacity-=18
   for i in 0...6
     @sprites["box#{i}"].opacity-=18
   end
      for i in 0...$Trainer.party.length
   @sprites["party#{i}"].opacity-=18
   end
      break if @sprites["bgback"].opacity==0
    end
    pbDisposeSpriteHash(@sprites) #jv
    end
    
  def pbScene
    loop do
      @oldindex=@index
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B) || @done
        pbCloseMenu
        break
      end
    end
  end
  
 def update 
   if Input.trigger?(Input::A) and $DEBUG
      pbFadeOutIn(99999) { 
      pbDebugMenu
        }
   end
   
    if Input.trigger?(Input::LEFT)
      @index > 0 ? @index-=1 : @index=@commands.length-1
      updateSelection
    elsif Input.trigger?(Input::RIGHT)
      @index < @commands.length-1 ? @index+=1 : @index=0
      updateSelection

    elsif Input.trigger?(Input::C)
      pbSEPlay("Select")
      case @commands[@index]
      when "Pokedex"
        pbFadeOutIn(99999) {
           scene = PokemonPokedex_Scene.new
           screen = PokemonPokedexScreen.new(scene)
           screen.pbStartScreen
        }
      when "Pokemon"
        hiddenmove = nil
        pbFadeOutIn(99999){ 
          sscene = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          hiddenmove = sscreen.pbPokemonScreen
        }
        if hiddenmove
          $game_temp.in_menu = false
          Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return
        end
=begin
        hiddenmove=nil
        pbFadeOutIn(99999) {
           sscene = PokemonParty_Scene.new
           sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
           sscreen.pbPokemonScreen
           hiddenmove=sscreen.pbPokemonScreen
           if hiddenmove
             for sprite in @sprites
         sprite[1].visible = false
        end
        @done=true
           end
        }
        if hiddenmove
          Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return
        end
=end
      when "Bag"
        item=0
        scene=PokemonBag_Scene.new
        screen=PokemonBagScreen.new(scene,$PokemonBag)
        pbFadeOutIn(99999) { 
         item=screen.pbStartScreen 
          if item>0
        for sprite in @sprites
         sprite[1].visible = false
        end
        @done=true
           end
        }
        if item>0
          Kernel.pbUseKeyItemInField(item)
          return
        end
      when "Craft"
        #Call the item crafter script here...
        pbFadeOutIn(99999) {
          ItemCrafterScene.new
        }
      when "I.D."
        scene = PokemonTrainerCard_Scene.new
        screen = PokemonTrainerCardScreen.new(scene)
        pbFadeOutIn(99999) { 
          screen.pbStartScreen
        }
      when "Save"
        #hide all sprites
        for sprite in @sprites
          #[0] is the sprite name, [1] is the image
          sprite[1].visible = false
        end
        scene = PokemonSave_Scene.new
        screen = PokemonSaveScreen.new(scene)
        if screen.pbSaveScreen
          @done=true
        else
          #make all sprites visible again
          for sprite in @sprites
            sprite[1].visible = true
          end
        end
      when "Options"
        scene = PokemonOption_Scene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen
           pbUpdateSceneMap
        }
      when "Exit"
           #pbCloseMenu
           @done = true
      end
    end
    pbUpdateSpriteHash(@sprites)
  end
  
def updateSelection
  
   @sprites["info"].bitmap.clear
   drawTextEx(@sprites["info"].bitmap,14,102,280,0,pbInfo(@commands[@index]),Color.new(255,255,255),Color.new(96,96,96))
  
 case @commands[@index]
      when "Pokedex" 
 @sprites["dex"].opacity=255 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity=150 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity=150 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity=150 if $game_variables[117] != 2
 @sprites["card"].opacity=150
 @sprites["save"].opacity=150
 @sprites["options"].opacity=150
 @sprites["exit"].opacity=150
      when "Pokemon"
 @sprites["dex"].opacity=150 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity=255 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["bag"].opacity=150 if $game_variables[117] != 2
 @sprites["craft"].opacity=150 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["card"].opacity=150
 @sprites["save"].opacity=150
 @sprites["options"].opacity=150
 @sprites["exit"].opacity=150
      when "Bag"
       @sprites["dex"].opacity=150 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity=150 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity=150 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity=255 if $game_variables[117] != 2
 @sprites["card"].opacity=150
 @sprites["save"].opacity=150
 @sprites["options"].opacity=150
 @sprites["exit"].opacity=150
      when "Craft"
         @sprites["dex"].opacity=150 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity=150 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity=255 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity=150 if $game_variables[117] != 2
 @sprites["card"].opacity=150
 @sprites["save"].opacity=150
 @sprites["options"].opacity=150
 @sprites["exit"].opacity=150
      when "I.D."
       @sprites["dex"].opacity=150 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity=150 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity=150 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity=150 if $game_variables[117] != 2
 @sprites["card"].opacity=255
 @sprites["save"].opacity=150
 @sprites["options"].opacity=150
 @sprites["exit"].opacity=150
      when "Save"
         @sprites["dex"].opacity=150 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity=150 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity=150 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity=150 if $game_variables[117] != 2
 @sprites["card"].opacity=150
 @sprites["save"].opacity=255
 @sprites["options"].opacity=150
 @sprites["exit"].opacity=150
      when "Options"
         @sprites["dex"].opacity=150 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity=150 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity=150 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity=150 if $game_variables[117] != 2
 @sprites["card"].opacity=150
 @sprites["save"].opacity=150
 @sprites["options"].opacity=255
 @sprites["exit"].opacity=150
  when "Exit"
 @sprites["dex"].opacity=150 if $Trainer.pokedex==true && $game_variables[117] != 2
 @sprites["pokemon"].opacity=150 if $Trainer.party.length>0 && $game_variables[117] != 2
 @sprites["craft"].opacity=150 if $Trainer.itemCrafter==true && $game_variables[117] != 2
 @sprites["bag"].opacity=150 if $game_variables[117] != 2
 @sprites["card"].opacity=150
 @sprites["save"].opacity=150
 @sprites["options"].opacity=150
 @sprites["exit"].opacity=255
      end
  end
    
  
  def pbEndScene
    pbDisposeSpriteHash(@sprites)
  end
  
end

class MenuScreen
  
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbScene
    @scene.pbEndScene
  end

end#class end

def pbNewMenu
     sscene=Menu.new
    sscreen=MenuScreen.new(sscene) 
    sscreen.pbStartScreen 
  end